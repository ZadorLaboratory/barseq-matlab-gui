function [miss_table,folder_upload_table,file_upload_table,missing_correct]=aws_check_missing_file(app,aws_table,check_table,disk)
aws_table.filename=erase(aws_table.a_name, {'/'});
check_table = check_table(~endsWith(check_table.t_name, '_localdisksummary.txt'), :);
check_table.filename = erase(check_table.t_name, {disk,'\'});
check_table.filefoldername=cellfun(@get_folder, check_table.t_name, 'UniformOutput', false);
check_table.filefoldername=categorical(check_table.filefoldername);
[C,ia,ic] = unique(check_table.filefoldername);
a_counts = accumarray(ic,1);
varNames = ["foldername","check_table_count"];
check_table_folder_counts = table(C, a_counts,'VariableNames',varNames);
full=outerjoin(check_table, aws_table, 'MergeKeys', true,'Type','left');
loc_2=cellfun('isempty', full{:,'a_name'} );
miss_table=full(loc_2,{'t_name','t_size','filefoldername'});
miss_row=height(miss_table);
folder_upload_list={};
b={};
if miss_row==0
    app.MessageTextArea.FontColor=[1 0 0];
    app.MessageTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf('All files in this folder are already uploaded.')}];
    missing_correct=1;
else
    missing_correct=0;
    miss_table.filefoldername=cellfun(@get_folder, miss_table.t_name, 'UniformOutput', false);
    miss_table.filefoldername=categorical(miss_table.filefoldername);
    [C,ia,ic] = unique(miss_table.filefoldername);
    a_counts = accumarray(ic,1);
    varNames = ["foldername","missing_table_count"];
    miss_table_folder_counts = table(C, a_counts,'VariableNames',varNames);
    full_check=join(check_table_folder_counts,miss_table_folder_counts);
    for i = 1:length(full_check.foldername)
        b{i,1}=char(sprintf('Folder Name is: %s\n, File number inside this folder is:%s, Missing file in this folder is %s \n ',[full_check.foldername(i),num2str(full_check.check_table_count(i)),num2str(full_check.missing_table_count(i))] ));
        if ((full_check.check_table_count(i)==full_check.missing_table_count(i)) || (full_check.missing_table_count(i)<=100) )&& (full_check.foldername(i)~='singlefile')
            name=full_check.foldername(i);
            folder_upload_list{end+1}=name;
        end
    end 
     app.MessageTextArea.Value=b; 
     folder_upload_table=cell2table(folder_upload_list');
     folder_upload_table=renamevars(upload_file_table,["Var1"],["foldername"])
     file_upload_table=miss_table(~(ismember(miss_table.filefoldername,folder_upload_table.foldername)),:)  
     file_upload_table=renamevars(file_upload_table,["t_name"],["fullfilename"])
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