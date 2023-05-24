function scheduled_upload(app,datafolder,datafolderfull)
tic
app.MessageTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('uploading start!')}];
cmd=append('aws s3 sync ',datafolderfull,' s3://barseqtest/',datafolder,' --storage-class DEEP_ARCHIVE');
system(cmd);
toc
app.MessageTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('Finished at: %s',toc)}];