function [] = all_experiments_parallel(sub)
addpath(genpath('.'))

p = gcp('nocreate');
if isempty(p)
    p = parpool(24);
end

%% Load data
load('./info.mat')
exp = {};

for s = sub
    exp{s} = load_subject_data(s);
end

%% Create output directory
runtime = datestr(now,'yyyy-mm-dd_HH-MM-SS');
outputDir = ['./outputs/' runtime '/'];
mkdir(outputDir)

%% Loop through subjects and model parameters
feat = {@mav};
win = 50;
dim = 10000;
nLen = 5;

Nshot = [1];

% set up mesh for looping
[subGrid,featGrid,winGrid,dimGrid,nLenGrid] = ndgrid(sub,feat,win,dim,nLen);

numRuns = numel(subGrid);

%% Overall loop
tic
for ii = 1:numRuns
    % get subject
    subject = subGrid(ii);
    
    % create model
    model = struct;
    model.D = dimGrid(ii);
    model.N = nLenGrid(ii);
    model.period = winGrid(ii);
    model.noCh = 64;
    model.eM = containers.Map ('KeyType','int32','ValueType','any');
    for e = 1:1:model.noCh
        if ismember(e,subjectInfo(subject).exclude)
            model.eM(e) = zeros(1,model.D);
        else
            model.eM(e) = gen_random_HV(model.D);
        end
    end
    
    % select feature function
    featureFunc = featGrid{ii};
    funcStr = strrep(func2str(featureFunc),'_','-');
    if length(funcStr)>10
        funcStr = funcStr(1:10);
    end
    funcStr = pad(funcStr,10,'left','-');
    
    % get output file description
    fileDes = [sprintf('%03d',subject) '_' funcStr '_' sprintf('%03d',model.period) '_' sprintf('%02d',model.N) '_' sprintf('%05d',model.D)];
    fprintf([fileDes '\n'])
    fileDes = [outputDir fileDes];
    
    % run individual sessions
    session = 1;
    gestures = gestList{session};
    allData = exp{subject}{session};
    features = get_features(allData, model.period, featureFunc);
    outfname = [fileDes '-Session_' num2str(session)];
    jobs = parfeval(p,@crossvalidate_func,0,model,gestures,features,Nshot,outfname);
%     crossvalidate_func(model,gestures,features,Nshot,outfname);
    for session = 2:8
        gestures = gestList{session};
        allData = exp{subject}{session};
        features = get_features(allData, model.period, featureFunc);
        outfname = [fileDes '-Session_' num2str(session)];
        jobs(end+1) = parfeval(p,@crossvalidate_func,0,model,gestures,features,Nshot,outfname);
%         crossvalidate_func(model,gestures,features,Nshot,outfname);
    end
    
    % run baseline experiment
    gestures = allGest;
    allData = [exp{subject}{1}; exp{subject}{2}];
    features = get_features(allData, model.period, featureFunc);
    outfname = [fileDes '-Baseline_'];
    jobs(end+1) = parfeval(p,@crossvalidate_func,0,model,gestures,features,Nshot,outfname);
%     crossvalidate_func(model,gestures,features,Nshot,outfname);
    
    % run arm position experiment
    gestures = singleDOF;
    trainData = exp{subject}{1};
    testData = exp{subject}{3};
    trainFeatures = get_features(trainData, model.period, featureFunc);
    testFeatures = get_features(testData, model.period, featureFunc);
    outfname = [fileDes '-ArmPos___'];
    jobs(end+1) = parfeval(p,@newcontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,outfname);
%     newcontext_func(model,gestures,trainFeatures,testFeatures,Nshot,outfname);
    outfname = [fileDes '-ArmPosUpd'];
    jobs(end+1) = parfeval(p,@updatecontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
%     updatecontext_func(model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
    
    % run different day experiment
    gestures = singleDOF;
    trainData = exp{subject}{1};
    testData = exp{subject}{7};
    trainFeatures = get_features(trainData, model.period, featureFunc);
    testFeatures = get_features(testData, model.period, featureFunc);
    outfname = [fileDes '-DiffDay__'];
    jobs(end+1) = parfeval(p,@newcontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,outfname);
%     newcontext_func(model,gestures,trainFeatures,testFeatures,Nshot,outfname);
    outfname = [fileDes '-DiffDayUp'];
    jobs(end+1) = parfeval(p,@updatecontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
%     updatecontext_func(model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
    
    % run prolong experiment
    gestures = singleDOF;
    trainData = exp{subject}{7};
    testData = exp{subject}{8};
    trainFeatures = get_features(trainData, model.period, featureFunc);
    testFeatures = get_features(testData, model.period, featureFunc);
    outfname = [fileDes '-Prolong__'];
    jobs(end+1) = parfeval(p,@newcontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,outfname);
%     newcontext_func(model,gestures,trainFeatures,testFeatures,Nshot,outfname);
    outfname = [fileDes '-ProlongUp'];
    jobs(end+1) = parfeval(p,@updatecontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
%     updatecontext_func(model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
    
    % run effort level    
    % first treat effort level as if it were new context
    effTrain = [4 4 5 5 6 6];
    effTest = [5 6 4 6 4 5];
    for test = 1:length(effTrain)
        gestures = effortGest;
        trainData = exp{subject}{effTrain(test)};
        testData = exp{subject}{effTest(test)};
        trainFeatures = get_features(trainData, model.period, featureFunc);
        testFeatures = get_features(testData, model.period, featureFunc);
        outfname = [fileDes '-EffoCont' num2str(test)];
        jobs(end+1) = parfeval(p,@newcontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,outfname);
%         newcontext_func(model,gestures,trainFeatures,testFeatures,Nshot,outfname);
        outfname = [fileDes '-EffoUpda' num2str(test)];
        jobs(end+1) = parfeval(p,@updatecontext_func,0,model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
%         updatecontext_func(model,gestures,trainFeatures,testFeatures,Nshot,Nshot,outfname);
    end
    
    % test combined gestures
    effortLow = exp{subject}{4};
    effortMed = exp{subject}{5};
    effortHigh = exp{subject}{6};
    
    testData = struct([]);
    testData(1).data = [effortLow; effortMed; effortHigh];
    testData(1).gestures = effortGest;

    effortMedSep = effortMed;
    for i = 1:size(effortMedSep,1)
        for j = 1:size(effortMedSep,2)
            oldLabel = effortMedSep(i,j).label;
            oldLabel(oldLabel ~= 0) = oldLabel(oldLabel ~= 0) + 200;
            effortMedSep(i,j).label = oldLabel;
        end
    end

    effortHighSep = effortHigh;
    for i = 1:size(effortHighSep,1)
        for j = 1:size(effortHighSep,2)
            oldLabel = effortHighSep(i,j).label;
            oldLabel(oldLabel ~= 0) = oldLabel(oldLabel ~= 0) + 400;
            effortHighSep(i,j).label = oldLabel;
        end
    end

    testData(2).data = [effortLow; effortMedSep];
    testData(2).gestures = [effortGest effortGest+200];

    testData(3).data = [effortLow; effortHighSep];
    testData(3).gestures = [effortGest effortGest+400];

    testData(4).data = [effortMedSep; effortHighSep];
    testData(4).gestures = [effortGest+200 effortGest+400];

    testData(5).data = [effortLow; effortMedSep; effortHighSep];
    testData(5).gestures = [effortGest effortGest+200 effortGest+400];
    
    testName = {'low + med + high (same)';
        'low + med (separate)';
        'low + high (separate)';
        'med + high (separate)';
        'low + med + high (separate)'};

    for test = 1:length(testData)
        gestures = testData(test).gestures;
        allData = testData(test).data;
        features = get_features(allData, model.period, featureFunc);
        outfname = [fileDes '-EffoComb' num2str(test)];
        jobs(end+1) = parfeval(p,@crossvalidate_func,0,model,gestures,features,Nshot,outfname);
%         crossvalidate_func(model,gestures,features,Nshot,outfname);
    end

    if ~wait(jobs)
        break
    end
end
t = toc;
f = fopen([outputDir 'elapsed_time.txt'],'w');
fprintf(f ,[num2str(t) ' seconds']);
fclose(f);
delete(p);

end

