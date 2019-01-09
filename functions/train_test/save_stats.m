function save_stats(out, info, outfname)
    [actualGest, predictedGest, similarities, accTot] = get_stats(out);
    save(outfname,'info','accTot','actualGest','predictedGest','similarities','-v7.3')
end