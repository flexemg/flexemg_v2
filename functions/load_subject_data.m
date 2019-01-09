function [experiments] = load_subject_data(subject)
    load('./info.mat','subjectInfo','ex','gestList','dataDir');    

    experiments = cell(1,length(ex));
    for k = 1:length(ex)
        e = ex(k);
        experiments{k} = struct([]);
        gest = gestList{k};
        for i = 1:length(gest)
            d = dir([dataDir num2str(subject,'%03.f') '_' num2str(e) '_' num2str(gest(i),'%03.f') '*']);
            files = {d.name};
            folders = {d.folder};
            % load all files associated with this gesture
            for j = 1:length(files)
                load([folders{j} '/' files{j}]);
                experiments{k}(i,j).raw = data;
                experiments{k}(i,j).label = label;
                clearvars data label
            end
        end
    end
end