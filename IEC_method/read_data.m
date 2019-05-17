function Data=read_data(Folder,File,N_Header,N_Data)

fileID=fopen(strcat(Folder,'/',File,'.txt'));

Data = textscan(fileID,'%d %f %f %f %f %f %f',N_Data,'HeaderLines',N_Header);

fclose(fileID);