function [features] = get_features(allData, windowSize, featureFunc)
    numGestures = size(allData,1);
    numTrials = size(allData,2);
    features = struct([]);
    for g = 1:numGestures
        for tr = 1:numTrials
            data = allData(g,tr).raw;
            label = select_data(allData(g,tr).label);
            ind = find(label ~= 0);
            data = data(ind,:);
            label = label(ind);
            
            numWin = floor(length(ind)/windowSize);
            numChannels = size(data,2);
            
            val = zeros(numChannels,numWin);
            featLabel = zeros(numWin,1);
            for i = 1:numWin
                featLabel(i) = mode(label((1:windowSize)+(i-1)*windowSize));
                for ch = 1:numChannels
                    val(ch,i) = featureFunc(data((1:windowSize)+(i-1)*windowSize,ch));
                end
            end
           	features(g,tr).values = val';
            features(g,tr).label = featLabel;
        end
    end
end