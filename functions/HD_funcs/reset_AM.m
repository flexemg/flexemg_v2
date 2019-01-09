function model = reset_AM(model, numTrials, gestures)
    model.AM = cell(1, numTrials);
    for tr = 1:numTrials
        model.AM{tr} = containers.Map('KeyType','int32','ValueType','any'); 
        for g = 1:length(gestures)
            model.AM{tr}(gestures(g)) = zeros(1,model.D);
        end
    end   
end