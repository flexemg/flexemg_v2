function [model] = train_model(model, features)
    numGests = size(features,1);
    numTrials = size(features,2);
    for g = 1:numGests
        for k = 1:numTrials
            trainData = features(g,k).values;
            trainLabel = features(g,k).label;
            model = train_trial(k,trainData,trainLabel,model,@ngram_HV);
        end
    end
end