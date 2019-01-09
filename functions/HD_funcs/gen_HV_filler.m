function randomHV = gen_HV_filler(D)
    randomIndex = randperm(D);
    % make half the elements 1 and the other half -1
    randomHV(randomIndex(1:floor(D/2))) = 1;
    randomHV(randomIndex(floor(D/2)+1:D)) = -1;
end
