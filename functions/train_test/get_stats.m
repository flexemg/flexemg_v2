function [actualGest, predictedGest, similarities, accTot] = get_stats(out)
    matchTot = 0;
    lenTot = 0;
    actualGest = [];
    predictedGest = [];
    similarities = [];
    for c = 1:size(out,1)
        for g = 1:size(out,2)
            for k = 1:size(out,3)
                matchTot = matchTot + out(c,g,k).matches;
                lenTot = lenTot + out(c,g,k).len;
                actualGest = [actualGest out(c,g,k).test];
                predictedGest = [predictedGest out(c,g,k).out];
                similarities = [similarities; out(c,g,k).sims];
            end
        end
    end
    accTot = matchTot/lenTot;
end