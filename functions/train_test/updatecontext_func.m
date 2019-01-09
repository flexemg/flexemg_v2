function updatecontext_func(model, gestures, trainFeatures, testFeatures, Nshotold, Nshotnew, outfname)

    numTrials = size(trainFeatures,2);
    internal_model_old = model;
    internal_model_old = reset_AM(internal_model_old, numTrials, gestures);
    internal_model_old = train_model(internal_model_old, trainFeatures);
    
    internal_model_new = model;
    internal_model_new = reset_AM(internal_model_new, numTrials, gestures);
    internal_model_new = train_model(internal_model_new, testFeatures);
    
    info.gestures = gestures;
    info.trainFeatures = trainFeatures;
    info.testFeatures = testFeatures;
    info.model_old = internal_model_old;
    info.model_new = internal_model_new;
    
    for n_old = Nshotold
        for n_new = Nshotnew
            info.Nshotold = n_old;
            info.Nshotnew = n_new;
            [outNew, outOld] = test_update_context(trainFeatures,testFeatures,internal_model_old,internal_model_new,n_old,n_new);
            outfnameN = [outfname '-' num2str(n_old) '-' num2str(n_new) '-new'];
            save_stats(outNew, info, outfnameN)
            outfnameN = [outfname '-' num2str(n_old) '-' num2str(n_new) '-old'];
            save_stats(outOld, info, outfnameN)
        end
    end

end