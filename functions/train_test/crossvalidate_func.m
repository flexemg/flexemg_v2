function crossvalidate_func(model, gestures, features, Nshot, outfname)
    numTrials = size(features,2);
    internal_model = model;
    internal_model = reset_AM(internal_model, numTrials, gestures);
    internal_model = train_model(internal_model, features);
    
    info.gestures = gestures;
    info.features = features;
    info.model = internal_model;
    
    for n = Nshot
        info.Nshot = n;
        out = test_cross_validate(internal_model,features,n);
        outfnameN = [outfname '-' num2str(n) '-' num2str(n)];
        save_stats(out, info, outfnameN)
    end

end