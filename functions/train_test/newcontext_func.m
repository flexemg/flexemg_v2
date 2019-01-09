function newcontext_func(model, gestures, trainFeatures, testFeatures, Nshot, outfname)

    numTrials = size(trainFeatures,2);
    internal_model = model;
    internal_model = reset_AM(internal_model, numTrials, gestures);
    internal_model = train_model(internal_model, trainFeatures);
    
    info.gestures = gestures;
    info.trainFeatures = trainFeatures;
    info.testFeatures = testFeatures;
    info.model = internal_model;
    
    for n = Nshot
        info.Nshot = n;
        out = test_new_context(internal_model,testFeatures,n);
        outfnameN = [outfname '-' num2str(n) '-' num2str(n)];
        save_stats(out, info, outfnameN)
    end

end