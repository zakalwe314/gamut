function Header=read_header(Folder,File,N)

% Read .txt data file
fileID=fopen(strcat(Folder,'/',File,'.txt'));

Header=cell(3,1);

for n=1:N
    Header{n}=fgetl(fileID);
end

fclose(fileID);

