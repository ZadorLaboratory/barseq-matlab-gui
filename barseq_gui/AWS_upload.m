function AWS_upload(dataforlder,cycle_name)
datafolder=dataforlder;
datafolderfull=append('E:\',dataforlder);
cycle_name=cycle_name;
cmd1=append('start aws s3 cp ',datafolderfull,'\',cycle_name,' s3://barseqtest/',datafolder,'/',cycle_name,'/ --storage-class DEEP_ARCHIVE');
%cmd2=append('start aws s3 sync ',datafolderfull,'\',cycle_name,'.csv',' s3://barseqtest/',datafolder,'/ --storage-class DEEP_ARCHIVE');
%cmd3=append('start aws s3 sync ',datafolderfull,'\','offset',cycle_name,'.csv',' s3://barseqtest/',datafolder,'/ --storage-class DEEP_ARCHIVE');
cmd4=append('start aws s3 cp ',datafolderfull,'\','regoffset',cycle_name,'.csv',' s3://barseqtest/',datafolder,'/ --storage-class DEEP_ARCHIVE');
%cmd5=append('start aws s3 sync ',datafolderfull,'\','tiledregoffset',cycle_name,'.csv',' s3://barseqtest/',datafolder,'/ --storage-class DEEP_ARCHIVE');
%cmd6=append('start /min aws s3 sync ',datafolderfull,'\','dicfocus',cycle_name,' s3://barseqtest/',datafolder,'/dicfocus',cycle_name,'/ --storage-class DEEP_ARCHIVE');
%cmd7=append('start /min aws s3 sync ',datafolderfull,'\','focus',cycle_name,' s3://barseqtest/',datafolder,'/focus',cycle_name,'/ --storage-class DEEP_ARCHIVE');
system(cmd1);
system(cmd4);



