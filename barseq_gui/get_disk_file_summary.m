function [uploadfoldersummary]=get_disk_file_summary(datafolder,datafolderfull)
cd(datafolderfull);
cmd=append('(for /R ".\" %A in (*.*) do echo %~fA %~zA) | findstr /v "echo" >',datafolder,'_localdisksummary.txt');
system(cmd);
cpfile=append(datafolder,'_localdisksummary.txt');
destination='C:\Users\aixin.zhang\OneDrive - Allen Institute\Allenwork\Project\AWS_management';
movefile(cpfile,destination);
cd('C:\Users\aixin.zhang\OneDrive - Allen Institute\Allenwork\Project\AWS_management')
filename=append(datafolder,'_localdisksummary.txt');
uploadfoldersummary = readtable(filename,'Format','%s%f');
uploadfoldersummary.Properties.VariableNames = ["t_name","t_size"];