function avail_space = get_available_space(dick_type,dickname)
       if dick_type=='local'
           disk=append(dickname,':\');
           avail_space =getFreeSpace(disk);
       elseif dick_type=='mounted'
           cmd='for /f "tokens=5 delims= " %i in (''ssh imagestorage@barseqstorage0 df ^| findstr md1'') DO @echo %i';
           [status,cmdout]=system(cmd);
           avail_space =str2double(cmdout)
       end
end