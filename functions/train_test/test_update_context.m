function [outNew, outOld] = test_update_context(oldFeatures, newFeatures, oldModel, newModel, oldN, newN)
    numGests = size(oldFeatures,1);
    numTrials = size(oldFeatures,2);
    outNew = struct([]);
    outOld = struct([]);
    
    oldConfigs = nchoosek(1:numTrials,oldN);
    numOldConfigs = size(oldConfigs,1);
    oldTestTrials = zeros(numOldConfigs,numTrials-oldN);
    for i = 1:numOldConfigs
        oldTestTrials(i,:) = setdiff(1:numTrials,oldConfigs(i,:));
    end
    
    newConfigs = nchoosek(1:numTrials,newN);
    numNewConfigs = size(newConfigs,1);
    newTestTrials = zeros(numNewConfigs,numTrials-newN);
    for i = 1:numNewConfigs
        newTestTrials(i,:) = setdiff(1:numTrials,newConfigs(i,:));
    end
    
    testAM = cell(numNewConfigs,numOldConfigs);
            
%     % update context with accumulation
%     for i = 1:numNewConfigs
%         for j = 1:numOldConfigs
%             testAM{i,j} = containers.Map('KeyType','int32','ValueType','any');
%             gestures = oldModel.AM{1}.keys;
%             for g = 1:length(gestures)
%                 testAM{i,j}(gestures{g}) = zeros(1,oldModel.D);
%                 for tr = 1:oldN
%                     testAM{i,j}(gestures{g}) = testAM{i,j}(gestures{g}) + oldModel.AM{oldConfigs(j,tr)}(gestures{g});
%                 end
%                 for tr = 1:newN
%                     testAM{i,j}(gestures{g}) = testAM{i,j}(gestures{g}) + newModel.AM{newConfigs(i,tr)}(gestures{g});
%                 end
%             end
%             bipolarize_AM(testAM{i,j});
%         end
%     end
    
    % update context with bitwise merge
    for i = 1:numNewConfigs
        for j = 1:numOldConfigs
            testAM{i,j} = containers.Map('KeyType','int32','ValueType','any');
            gestures = oldModel.AM{1}.keys;
            for g = 1:length(gestures)
                oldVec = zeros(1,oldModel.D);
                for tr = 1:oldN
                    oldVec = oldVec + oldModel.AM{oldConfigs(j,tr)}(gestures{g});
                end
                oldVec = bipolarize_vec(oldVec);
                newVec = zeros(1,newModel.D);
                for tr = 1:newN
                    newVec = newVec + newModel.AM{newConfigs(i,tr)}(gestures{g});
                end
                newVec = bipolarize_vec(newVec);
                % merge vectors
                mergeVec = zeros(1,oldModel.D);
                mergeInd = randperm(oldModel.D);
                oldNum = round(oldModel.D*(oldN/(oldN + newN)));
                mergeVec(mergeInd(1:oldNum)) = oldVec(mergeInd(1:oldNum));
                mergeVec(mergeInd(oldNum+1:end)) = newVec(mergeInd(oldNum+1:end));
                testAM{i,j}(gestures{g}) = mergeVec;
            end
        end
    end
    
    % test new data first
    for g = 1:numGests
        for trial = 1:numTrials
            testData = newFeatures(g,trial).values;
            testLabel = newFeatures(g,trial).label';
            testLength = size(testData,1);
            
            [testIdx,c] = find(newTestTrials == trial);
            numNewTests = length(unique(testIdx));
            numTotalTests = numNewTests*numOldConfigs;
            
            sims = zeros(numTotalTests, testLength, length(gestures));
            outLabel = zeros(numTotalTests, testLength);

            for i = 1:testLength-oldModel.N+1
                segment = testData(i:i+oldModel.N-1, :);
                ngram = ngram_HV(segment, oldModel);
                for c = 1:numNewTests
                    for d = 1:numOldConfigs
                        [sims(c + (d-1)*numNewTests,i,:), outLabel(c + (d-1)*numNewTests,i)] = classify_HV(ngram, testAM{testIdx(c),d});
                    end
                end
            end
            
            for c = 1:numTotalTests
                outNew(c,g,trial).test = testLabel(1:end-oldModel.N+1);
                outNew(c,g,trial).out = outLabel(c,1:end-oldModel.N+1);
                outNew(c,g,trial).sims = squeeze(sims(c,1:end-oldModel.N+1,:));
                outNew(c,g,trial).matches = sum(outNew(c,g,trial).test == outNew(c,g,trial).out);
                outNew(c,g,trial).len = testLength-oldModel.N+1;
                outNew(c,g,trial).accuracy = outNew(c,g,trial).matches/outNew(c,g,trial).len;
            end
          
        end
    end
    
    % test old data
    for g = 1:numGests
        for trial = 1:numTrials
            testData = oldFeatures(g,trial).values;
            testLabel = oldFeatures(g,trial).label';
            testLength = size(testData,1);
            
            [testIdx,c] = find(oldTestTrials == trial);
            numOldTests = length(unique(testIdx));
            numTotalTests = numOldTests*numNewConfigs;
            
            sims = zeros(numTotalTests, testLength, length(gestures));
            outLabel = zeros(numTotalTests, testLength);

            for i = 1:testLength-oldModel.N+1
                segment = testData(i:i+oldModel.N-1, :);
                ngram = ngram_HV(segment, oldModel);
                for c = 1:numOldTests
                    for d = 1:numNewConfigs
                        [sims(c + (d-1)*numOldTests,i,:), outLabel(c + (d-1)*numOldTests,i)] = classify_HV(ngram, testAM{d,testIdx(c)});
                    end
                end
            end
            
            for c = 1:numTotalTests
                outOld(c,g,trial).test = testLabel(1:end-oldModel.N+1);
                outOld(c,g,trial).out = outLabel(c,1:end-oldModel.N+1);
                outOld(c,g,trial).sims = squeeze(sims(c,1:end-oldModel.N+1,:));
                outOld(c,g,trial).matches = sum(outOld(c,g,trial).test == outOld(c,g,trial).out);
                outOld(c,g,trial).len = testLength-oldModel.N+1;
                outOld(c,g,trial).accuracy = outOld(c,g,trial).matches/outOld(c,g,trial).len;
            end
          
        end
    end
    
end