function [ngram] = ngram_HV(procData, model)
    ngram = zeros(1, model.D);
    dataLength = size(procData, 1);
    for i = 1:dataLength-model.N+1
        temp = ones(1, model.D);
        for t = 1:model.N
            s = zeros(1, model.D);
            for e = 1:model.noCh
                s = s + model.eM(e).*procData(t,e);
            end
            numzeros = sum(s==0);
            filler = gen_HV_filler(numzeros);
            s(s == 0) = filler;
            s(s > 0) = 1;
            s(s < 0) = -1;
            
            temp = temp.*(circshift(s, [0, model.N - t]));
        end
        ngram = ngram + temp;
    end
end