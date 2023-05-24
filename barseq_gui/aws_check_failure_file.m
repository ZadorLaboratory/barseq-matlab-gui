function [failure_file_table,folder_upload_table,file_upload_table,failure_correct]=aws_check_failure_file(app,aws_table,check_table,disk)
aws_table.filename=erase(aws_table.a_name, {'/'});
check_table = check_table(~endsWith(check_table.Var1, '_check.txt'), :);
check_table.filename = erase(check_table.t_name, {disk,'\'});
check_table.filefoldername=cellfun(@get_folder, check_table.t_name, 'UniformOutput', false);
check_table.filefoldername=categorical(check_table.filefoldername);
[C,ia,ic] = unique(check_table.filefoldername);
a_counts = accumarray(ic,1);
varNames = ["foldername","check_table_count"];
check_table_folder_counts = table(C, a_counts,'VariableNames',varNames);
full=outerjoin(check_table, aws_table, 'MergeKeys', true,'Type','left');
failure_file= rmmissing(full);
failure_file_table=failure_file(~(failure_file.t_size==failure_file.a_size),:);
H = height(failure_file_table);
b={};
folder_upload_list={};
if H ==0
    app.MessageTextArea.FontColor=[1 0 0];
    app.MessageTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf('Uploaded files size in this folder are correct.')}];
    failure_correct=1;
else
    failure_correct=0;
    failure_file_table.filefoldername=cellfun(@get_folder, check_table.t_name, 'UniformOutput', false);
    failure_file_table.filefoldername=categorical(failure_file_table.filefoldername);
    [C,ia,ic] = unique(failure_file_table.filefoldername);
    a_counts = accumarray(ic,1);
    varNames = ["foldername","failure_table_count"];
    failure_file_table_folder_counts = table(C, a_counts,'VariableNames',varNames);
    full_check=join(check_table_folder_counts,failure_file_table_folder_counts);
    for i = 1:length(full_check.foldername)
        b{i,1}=char(sprintf('Folder Name is: %s\n, File number inside this folder is:%s, Failure file in this folder is %s \n ',[full_check.foldername(i),num2str(full_check.check_table_count(i)),num2str(full_check.failure_table_count(i))] ));
        if ((full_check.check_table_count(i)==full_check.failure_table_count(i)) || ((full_check.check_table_count(i)-full_check.failure_table_count(i))<=100) )&& (full_check.foldername(i)~='singlefile')
        folder_upload=full_check.foldername(i);
        folder_upload_list{end+1} =folder_upload;
        end 
    end 
     app.MessageTextArea.Value=b; 
     folder_upload_table=cell2table(folder_upload_list');
     folder_upload_table=renamevars(folder_upload_table,["Var1"],["foldername"]);
     file_upload_table=failure_file_table(~(ismember(failure_file_table.filefoldername,folder_upload_list.foldername)),:);
     file_upload_table=renamevars(file_upload_table,["t_name"],["fullfilename"]);
     
end

end
% local function
function result=get_folder(x)
    a = strsplit(x, '\');
    if size(a,2) == 3
        result = 'singlefile';
    else
        result = a{3};
    end
end