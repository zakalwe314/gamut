function [Data,filename] = ui_read_data(pattern)
    [filename,path] = uigetfile(pattern);
    file = fopen([path '/' filename]);
    Data={[]};
    while(isempty(Data{1}))
        fgetl(file);
        Data = textscan(file,'%d %f %f %f %f %f %f',3460);
    end
    fclose(file);
end

