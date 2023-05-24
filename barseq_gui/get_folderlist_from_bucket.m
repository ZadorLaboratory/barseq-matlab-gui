function [folder_name_list]=get_folderlist_from_bucket()
cd('C:\Users\Chen Lab CREST\Desktop\AWS_Management');
cmd='aws s3 ls s3://barseqtest >bucket_summary.txt';
system(cmd);
bucket_summary_t = readtable('bucket_summary.txt','Format','%s%s','VariableNamingRule','preserve');
folder_name_list=erase(bucket_summary_t{:,2}, '/');