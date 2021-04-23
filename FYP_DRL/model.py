import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
#device = torch.device('cpu')


class Encoder(nn.Module):
    """Encodes the static & dynamic states using 1d Convolution."""

    def __init__(self, input_size, hidden_size):
        super(Encoder, self).__init__()
        self.conv = nn.Conv1d(input_size, hidden_size, kernel_size=1)

    def forward(self, input):
        output = self.conv(input)
        return output  # (batch, hidden_size, seq_len)


class Attention(nn.Module):
    """Calculates attention over the input nodes given the current state."""

    def __init__(self, hidden_size):
        super(Attention, self).__init__()

        # W processes features from static decoder elements
        self.v = nn.Parameter(torch.zeros((1, 1, hidden_size),
                                          device=device, requires_grad=True))

        self.W = nn.Parameter(torch.zeros((1, hidden_size, 3 * hidden_size),
                                          device=device, requires_grad=True))

    def forward(self, static_hidden, dynamic_hidden, decoder_hidden):

        batch_size, hidden_size, _ = static_hidden.size()

        #print(_)#:显示每个子问题显示N个N（N为测试城市数量）

        hidden = decoder_hidden.unsqueeze(2).expand_as(static_hidden)
        hidden = torch.cat((static_hidden, dynamic_hidden, hidden), 1)

        # Broadcast some dimensions so we can do batch-matrix-multiply
        v = self.v.expand(batch_size, 1, hidden_size)
        W = self.W.expand(batch_size, hidden_size, -1)

        attns = torch.bmm(v, torch.tanh(torch.bmm(W, hidden)))
        attns = F.softmax(attns, dim=2)  # (batch, seq_len)
        return attns


class Pointer(nn.Module):
    """Calculates the next state given the previous state and input embeddings."""

    def __init__(self, hidden_size, num_layers=1, dropout=0.2):
        super(Pointer, self).__init__()

        self.hidden_size = hidden_size
        self.num_layers = num_layers

        # Used to calculate probability of selecting next state
        self.v = nn.Parameter(torch.zeros((1, 1, hidden_size),
                                          device=device, requires_grad=True))

        self.W = nn.Parameter(torch.zeros((1, hidden_size, 2 * hidden_size),
                                          device=device, requires_grad=True))

        # Used to compute a representation of the current decoder output
        # GRU（输入dim，隐含层dim，层数）
        self.gru = nn.GRU(hidden_size, hidden_size, num_layers,
                          batch_first=True,
                          dropout=dropout if num_layers > 1 else 0)
        self.encoder_attn = Attention(hidden_size)

        self.drop_rnn = nn.Dropout(p=dropout)
        self.drop_hh = nn.Dropout(p=dropout)

    def forward(self, static_hidden, dynamic_hidden, decoder_hidden, last_hh):

        rnn_out, last_hh = self.gru(decoder_hidden.transpose(2, 1), last_hh)
        rnn_out = rnn_out.squeeze(1)

        # Always apply dropout on the RNN output
        rnn_out = self.drop_rnn(rnn_out)
        if self.num_layers == 1:
            # If > 1 layer dropout is already applied
            last_hh = self.drop_hh(last_hh)

        # Given a summary of the output, find an  input context
        enc_attn = self.encoder_attn(static_hidden, dynamic_hidden, rnn_out)
        context = enc_attn.bmm(static_hidden.permute(0, 2, 1))  # (B, 1, num_feats)

        # Calculate the next output using Batch-matrix-multiply ops
        context = context.transpose(1, 2).expand_as(static_hidden)
        energy = torch.cat((static_hidden, context), dim=1)  # (B, num_feats, seq_len)

        v = self.v.expand(static_hidden.size(0), -1, -1)
        W = self.W.expand(static_hidden.size(0), -1, -1)

        probs = torch.bmm(v, torch.tanh(torch.bmm(W, energy))).squeeze(1)

        return probs, last_hh


class DRL4TSP(nn.Module):
    """Defines the main Encoder, Decoder, and Pointer combinatorial models.

    Parameters
    ----------
    static_size: int
        Defines how many features are in the static elements of the model
        (e.g. 2 for (x, y) coordinates)
    dynamic_size: int > 1
        Defines how many features are in the dynamic elements of the model
        (e.g. 2 for the VRP which has (load, demand) attributes. The TSP doesn't
        have dynamic elements, but to ensure compatility with other optimization
        problems, assume we just pass in a vector of zeros.
    hidden_size: int
        Defines the number of units in the hidden layer for all static, dynamic,
        and decoder output units.
    update_fn: function or None
        If provided, this method is used to calculate how the input dynamic
        elements are updated, and is called after each 'point' to the input element.
    mask_fn: function or None
        Allows us to specify which elements of the input sequence are allowed to
        be selected. This is useful for speeding up training of the networks,
        by providing a sort of 'rules' guidlines to the algorithm. If no mask
        is provided, we terminate the search after a fixed number of iterations
        to avoid tours that stretch forever
    num_layers: int
        Specifies the number of hidden layers to use in the decoder RNN
    dropout: float
        Defines the dropout rate for the decoder
    """

    def __init__(self, static_size, dynamic_size, hidden_size,
                 update_fn=None, mask_fn=None, num_layers=1, dropout=0.):
        super(DRL4TSP, self).__init__()

        if dynamic_size < 1:
            raise ValueError(':param dynamic_size: must be > 0, even if the '
                             'problem has no dynamic elements')

        self.update_fn = update_fn
        self.mask_fn = mask_fn

        # Define the encoder & decoder models
        self.static_encoder = Encoder(static_size, hidden_size)
        self.dynamic_encoder = Encoder(dynamic_size, hidden_size)
        self.decoder = Encoder(static_size, hidden_size)
        self.pointer = Pointer(hidden_size, num_layers, dropout)

        for p in self.parameters():
            if len(p.shape) > 1:
                nn.init.xavier_uniform_(p)

        # Used as a proxy initial state in the decoder when not specified
        self.x0 = torch.zeros((1, static_size, 1), requires_grad=True, device=device)

    def forward(self, static, dynamic, decoder_input=None, last_hh=None):
        """
        Parameters
        ----------
        static: Array of size (batch_size, feats, num_cities)
            Defines the elements to consider as static. For the TSP, this could be
            things like the (x, y) coordinates, which won't change
        dynamic: Array of size (batch_size, feats, num_cities)
            Defines the elements to consider as static. For the VRP, this can be
            things like the (load, demand) of each city. If there are no dynamic
            elements, this can be set to None
        decoder_input: Array of size (batch_size, num_feats)
            Defines the outputs for the decoder. Currently, we just use the
            static elements (e.g. (x, y) coordinates), but this can technically
            be other things as well
        last_hh: Array of size (batch_size, num_hidden)
            Defines the last hidden state for the RNN
        """

        batch_size, input_size, sequence_size = static.size()

        if decoder_input is None:
            decoder_input = self.x0.expand(batch_size, -1, -1)
       
        # Always use a mask - if no function is provided, we don't update it
        mask = torch.ones(batch_size, sequence_size, device=device) # 1 * 10

        # print(mask)#:tensor([[1., 1., 1., 1., 1., 1., 1., 1., 1., 1.]], device='cuda:0')(城市数量10)
        #1 代表没去过

        # Structures for holding the output sequences
        tour_idx, tour_logp = [], []
        #print(sequence_size)#10(城市数量10)
        max_steps = sequence_size if self.mask_fn is None else 1000

        # print(max_steps)#1000

        # Static elements only need to be processed once, and can be used across
        # all 'pointing' iterations. When / if the dynamic elements change,
        # their representations will need to get calculated again.
        static_hidden = self.static_encoder(static)
        dynamic_hidden = self.dynamic_encoder(dynamic)

        mask_last2 = mask_last = mask  # 初始化mask_last
        now_1 = now_2 = 999
        for _ in range(max_steps):
            # print(_) #从0递增到城市数量10


            city1 = 0
            city2 = 5
            city_start = 0
            
            # 设置城市起点
            # if _ == 0:
            #     mask[:,:] = 0
            #     mask[:,city_start] = 1
            # if _ == 1:
            #     mask[:,:] = 1
            #     mask[:,city_start] = 0
            # print(mask)

            # 去过城市2后再去城市1
            # if (mask[:,city1] and mask[:,city2]):
            #     mask[:,city1] = 0 #城市1不能在城市2之前经过
            # elif (mask[:,city2] == 0 and mask_last[:,city2] == 1): #刚去过城市2
            #     # print('恢复城市1的权限')
            #     mask[:,city1] = 1 #恢复城市1的权限
            # mask_last = mask.tolist() #存储上一时刻的mask值
            # mask_last = numpy.mat(mask_last)
            # print(mask)
            
            # 城市1和城市2之间不允许通行
            # D = 20
            # if _ != D-1:
            #     if ((mask_last[:,city1] , mask_last[:,city2]) == (1 , 1) and mask[:,city1] == 0): #刚去过城市1
            #         mask[:,city2] = 0
            #         now_1 = _
            #     elif ((mask_last[:,city1] , mask_last[:,city2]) == (1 , 1) and mask[:,city2] == 0): #刚去过城市2
            #         mask[:,city1] = 0
            #         now_2 = _
            # if _ == now_1 + 1:
            #         mask[:, city2] = 1    
            # if _ == now_2 + 1:
            #         mask[:,city1] = 1
            # # print(mask)
            # mask_last = mask.tolist() #存储上一时刻的mask值
            # mask_last = numpy.mat(mask_last)

            # 去过城市1立刻去城市2,下面还有两行
            D = 20
            if (mask[:,city1] and mask[:,city2]):
                mask[:,city2] = 0 #城市2不能在城市1之前经过
            elif (mask[:,city1] == 0 and mask_last[:,city1] == 1): #刚去过城市1
                now_1 = _  #存储当前所在循环次数
                if now_1 == D-1:
                    mask[:,city2] = 1 
            mask_last = mask.tolist() #存储上一时刻的mask值
            mask_last = numpy.mat(mask_last)
            # print(mask)
           

            if not mask.byte().any():#if not 0.执行语句break(_=10) 所有城市去过了
                break

            # ... but compute a hidden rep for each element added to sequence


            decoder_hidden = self.decoder(decoder_input)

            probs, last_hh = self.pointer(static_hidden,
                                          dynamic_hidden,
                                          decoder_hidden, last_hh)
            # print(probs)
            probs = F.softmax(probs + mask.log(), dim=1)
            # print(probs)#输出当前这率步去10个城市的概率
            # When training, sample the next step according to its probability.
            # During testing, we can take the greedy approach and choose highest

            # # 设置出发起点
            # city_start = 7
            # if _ == 0:
            #     probs[:,city_start] = 100
            # #print(probs)

            #去过城市1立刻去城市2
            if _ == now_1:
                mask[:,city2] = 1
                probs[:,city2] = 100

            #loss关键
            if self.training:
                m = torch.distributions.Categorical(probs)

                # Sometimes an issue with Categorical & sampling on GPU; See:
                # https://github.com/pemami4911/neural-combinatorial-rl-pytorch/issues/5
                ptr = m.sample()
                while not torch.gather(mask, 1, ptr.data.unsqueeze(1)).byte().all():
                    ptr = m.sample()
                logp = m.log_prob(ptr)
            else:
                prob, ptr = torch.max(probs, 1)  # Greedy
                logp = prob.log()




            # After visiting a node update the dynamic representation
            if self.update_fn is not None:
                dynamic = self.update_fn(dynamic, ptr.data)
                dynamic_hidden = self.dynamic_encoder(dynamic)

                # Since we compute the VRP in minibatches, some tours may have
                # number of stops. We force the vehicles to remain at the depot
                # in these cases, and logp := 0
                is_done = dynamic[:, 1].sum(1).eq(0).float()
                logp = logp * (1. - is_done)

            # And update the mask so we don't re-visit if we don't need to
            if self.mask_fn is not None:
                mask = self.mask_fn(mask, dynamic, ptr.data).detach()

            tour_logp.append(logp.unsqueeze(1))
            # print('tour_logp',tour_logp)#每次多出来一个数
            tour_idx.append(ptr.data.unsqueeze(1))

            decoder_input = torch.gather(static, 2,
                                         ptr.view(-1, 1, 1)
                                         .expand(-1, input_size, 1)).detach()

        tour_idx = torch.cat(tour_idx, dim=1)  # (batch_size, seq_len)
        tour_logp = torch.cat(tour_logp, dim=1)  # (batch_size, seq_len)
        # print('tour_logp',tour_logp)
        # print('tour_idx',tour_idx)

        return tour_idx, tour_logp


if __name__ == '__main__':
    raise Exception('Cannot be called from main')
