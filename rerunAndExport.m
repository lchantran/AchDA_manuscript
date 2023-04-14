
for cdCounter=1:length(dirList)

    parentdir=dirList{cdCounter};
    cd(parentdir)
    disp(['SCANNING ' parentdir]);
    upperD=dir('processed_*');
    saveFolderUpper=[parentdir '/rerun/'];
    saveFolderJosh=[parentdir '/forJosh/'];
    mkdir(saveFolderUpper);
    mkdir(saveFolderJosh);

    for upperCounter=1:length(upperD)
        fileName=upperD(upperCounter).name;
        [~, fileName, ~]=fileparts(fileName);
        dd=strfind(fileName, '_');
        mouse=fileName(dd(1)+1:dd(2)-1);
        date=fileName(dd(2)+1:end);
        mouseList={mouse};
        dateList={date};
        saveFolder=saveFolderUpper;
        processNew_fast
        if exist('processed', 'var')
            cd(saveFolderJosh)
            extractForJosh
        else
            disp('analysis failed. Skipping extraction')
        end
        cd ~
    end
end