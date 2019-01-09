function [sims, label] = classify_HV(ngram, AM)
    classes = AM.keys;
    label = -1;
    maxSim = -1;
    sims = zeros(1,size(classes, 2));
    for i = 1:1:size(classes, 2)
        sims(i) = cosine_similarity(AM(cell2mat(classes(i))), ngram);
        if sims(i) > maxSim
            maxSim = sims(i);
            label = cell2mat(classes(i));
        end
    end
end