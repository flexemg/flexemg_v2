function [out, model] = test_new_context(model, features, N)
    numGests = size(features,1);
    numTrials = size(features,2);
    out = struct([]);
    
    configs = nchoosek(1:numTrials,N);
    numConfig = size(configs,1);
    
    testAM = cell(numConfig,1);
    for i = 1:numConfig
        testAM{i} = containers.Map('KeyType','int32','ValueType','any');
        gestures = model.AM{1}.keys;
        for g = 1:length(gestures)
            testAM{i}(gestures{g}) = zeros(1,model.D);
            for tr = 1:N
                testAM{i}(gestures{g}) = testAM{i}(gestures{g}) + model.AM{configs(i,tr)}(gestures{g});
            end
        end
        bipolarize_AM(testAM{i});
    end
    
    for trial = 1:numTrials
        for g = 1:numGests
            testData = features(g,trial).values;
            testLabel = features(g,trial).label';

            testLength = size(testData,1);
            sims = zeros(numConfig, testLength, length(gestures));
            outLabel = zeros(numConfig, testLength);

            for i = 1:testLength-model.N+1
                segment = testData(i:i+model.N-1, :);
                ngram = ngram_HV(segment, model);
                for c = 1:numConfig
                    [sims(c,i,:), outLabel(c,i)] = classify_HV(ngram, testAM{c});
                end
            end
            for c = 1:numConfig
                out(c,g,trial).test = testLabel(1:end-model.N+1);
                out(c,g,trial).out = outLabel(c,1:end-model.N+1);
                out(c,g,trial).sims = squeeze(sims(c,1:end-model.N+1,:));
                out(c,g,trial).matches = sum(out(c,g,trial).test == out(c,g,trial).out);
                out(c,g,trial).len = testLength-model.N+1;
                out(c,g,trial).accuracy = out(c,g,trial).matches/out(c,g,trial).len;
            end
        end
    end
end