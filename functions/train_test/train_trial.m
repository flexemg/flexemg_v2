function [model] = train_trial(tr, trainData, trainLabel, model, computeNgramFunc)
    % train data
    trainLength = size(trainData, 1); % total length of training data
    % loop over all FULL windows of data
    for i = 1:trainLength-model.N+1
        segment = trainData(i:i+model.N-1, :);
        ngram = computeNgramFunc(segment, model);
        model.AM{tr}(trainLabel(i)) = model.AM{tr}(trainLabel(i)) + ngram;
    end
end