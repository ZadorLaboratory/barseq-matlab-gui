function [awsfoldersummary]=get_aws_folder_summary(datafolder)
cd('C:\Users\aixin.zhang\OneDrive - Allen Institute\Allenwork\Project\AWS_Management\')
cmd1=append('aws s3 ls --recursive s3://barseqtest/',datafolder,'>',datafolder,'_awssummary.txt');
system(cmd1);
awsfilname_1=append(datafolder,'_awssummary.txt');
awsfoldersummary = readtable(awsfilname_1,'Format','%s%s%f%s');
awsfoldersummary.Properties.VariableNames = ["Date","Time","a_size","a_name"];

