%
%  Various GUI calls removed to simplify. 
%
%
%
%
%
%        



function GenerateMaxProjectionButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
           
            app.experiment_id=char(app.ExperimentIDEditField.Value);
            path=fullfile(app.acquisition_root,app.experiment_id);
            cd(path)

            f = waitbar(0,'Please wait...');
            %load('tformhyb.mat','tformhyb');
            %load('tformseq.mat','tformseq');
            load('tformsingle.mat','tformsingle');

            cycletype=app.CycletypeDropDown.Value;
            cyclenum=app.Cycle_numSpinner_3.Value;
            cycle_name=[cycletype,num2str(cyclenum,'%.2u')];
            app.person=app.TechnicianDropDown.Value;
            app.remote_storage=char(app.remote_loginEditField.Value);
            app.maxproj_folder=char(app.remote_rootEditField.Value);
            app.datafolder=char(app.ExperimentIDEditField.Value);
            
            switch cycletype
                case 'geneseq'
                    %tform=tformseq;
                    tform=tformsingle;
                    %dicch=2;
                    %focusch=1;
                    if cyclenum==1
                        
                        %ch_seq=[2 1 3 4 5]; tformch=[2 4];%original fast-seq
                        %ch_seq=[2 1 3 4 5 6 7] tformch=[2 4 6]; %fastseq with additiona C
                        ch_seq=[2 1 3 4 5]; tformch=[]; %single-seq
                    elseif cyclenum>1
                        %ch_seq=[2 1 3 4]; tformch=[2 4];
                        %ch_seq=[2 1 3 4 5 6];  tformch=[2 4 6];
                        ch_seq=[2 1 3 4]; tformch=[]; %single-seq
                    end
                case 'bcseq'
                    %tform=tformseq;
                    tform=tformsingle;
                    %dicch=2;
                    %focusch=1;
                    if cyclenum==1
                        %ch_seq=[2 1 3 4 5]; tformch=[2 4];%original fast-seq
                        %ch_seq=[2 1 3 4 5 6 7] tformch=[2 4 6]; %fastseq with additiona C
                        ch_seq=[2 1 3 4 5]; tformch=[]; %single-seq
                    else
                        %ch_seq=[2 1 3 4]; tformch=[2 4];
                        %ch_seq=[2 1 3 4 5 6];  tformch=[2 4 6];
                        ch_seq=[2 1 3 4]; tformch=[]; %single-seq
                    end
                case 'hyb'
                    %tform=tformhyb;
                    tform=tformsingle;
                    %dicch=2;
                    %focusch=1;
                    %ch_seq=[2 6 1 5 4 3]; tformch=[2 4 6]; % need to double check this
                    ch_seq=[1 5 2 6 3 4]; tformch=[]; %hyb using C1
            end
            

%            [~,I]=ismember(app.person,app.phonebook(:,1));
%            phone_num=char(app.phonebook(I,2));
%            serviceprovider=char(app.phonebook(I,3));
%             switch app.person
%                 case "Aixin Zhang'
%                     phone_num='1234567890';
%                     serviceprovider='tmobile';
%                 case 'User 2'
%                     phone_num='1234567890';
%                     serviceprovider='tmobile';
%             end
            
            %ch_seq=[2 1 3 4]; %if imaging without dic in a first cycle, use this.
             waitbar(.33,f,'Starting max projection');
             app.MessageTextArea.Value=sprintf('Starting max projection on cycle %s ', [cycletype,num2str(cyclenum,'%.2u')]);
             
             try
                niemaxprojimaging_gui(app,cycle_name,ch_seq,tformch,30,['Posinfo_regoffset',cycle_name,'.mat'], ...
                tform,app.remote_storage, ...
                [app.maxproj_root,app.experiment_id],fullfile(app.maxproj_root,app.experiment_id));
             catch ME % ME is of the class MException (in-built Matlab)
                str = sprintf(['Something is wrong with input files or setting. \n' 'Matlab says: \n' ME.message]);
                f_error = app.UIFigure;
                f_error.WindowStyle = 'modal';
                uialert(f_error, str, 'Input Files or Setting Error', 'Icon', 'error');
                close(f);
                app.InputcycleinformationButton.Enable='on';
                app.Step1CheckFocusingButton.Enable='on';
                app.Step2CheckAlignmentButton.Enable='on';
                app.CreateTilesButton.Enable='on';
                app.GenerateMaxProjectionButton.Enable='on';
               
                return
             end          
             app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {sprintf('Maxprojection Done!')}];
             % waitbar(.66,f,'transfering data files and checking if transfer is complete ...')
             % send_text_message(phone_num,serviceprovider,'Seq status:','Cycle finished');
             
             if ~isempty(app.remote_storage)
                [status,cmdout]=system(['ssh     ',app.remote_storage, ...
                    ' "ls ',app.maxproj_folder,app.datafolder,'/',cycle_name, ...
                    '/*.tif | wc -l" ']);
             end
             localfiles=dir(fullfile(app.Maxproj_drive,app.experiment_id,cycle_name,'*.tif'));
             
             if isempty(app.remote_storage)||numel(localfiles)==str2double(cmdout)
                app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {sprintf('Remote and Local file numbers match. Transfer complete!')}];
                aws=app.SendtoAWSDropDown.Value;
                switch aws
                    case 'Yes'
                    waitbar(0.88,f,' Maxprojection is done! Transfer files to AWS and Servers.');
                    app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {sprintf('Uploading to AWS')}];
                    if ~isempty(app.remote_storage)
                        transfer_to_data_storage(app.experiment_id,cycle_name);
                    end
                    pause(1)
                    AWS_upload(app.experiment_id,cycle_name)
                    close(f);
                    app.InputcycleinformationButton.Enable='on';
                    app.Step1CheckFocusingButton.Enable='on';
                    app.Step2CheckAlignmentButton.Enable='on';
                    app.CreateTilesButton.Enable='on';
                    app.GenerateMaxProjectionButton.Enable='on';

                case 'No'
                     waitbar(0.88,f,' Maxprojection is done! Transfer files to Servers.');
                     app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {sprintf('Maxprojection is done! Transfer files to Servers.')}];
                     if ~isempty(app.remote_storage)
                        transfer_to_data_storage(app.experiment_id,cycle_name);
                     end
                     close(f);
                     app.InputcycleinformationButton.Enable='on';
                     app.Step1CheckFocusingButton.Enable='on';
                     app.Step2CheckAlignmentButton.Enable='on';
                     app.CreateTilesButton.Enable='on';
                     app.GenerateMaxProjectionButton.Enable='on';
                end
            else
                close(f)
                send_text_message(phone_num,serviceprovider,'Seq error:','File numbers do not match');
                app.WarningTextArea.Value='Error: Remote and local file numbers do not match, please manually check files!';
                str = sprintf(['Remote and local file numbers do not match, please manually check files! \n' 'Matlab says: \n' ME.message]);
                f_error = app.UIFigure;
                f_error.WindowStyle = 'modal';
                uialert(f_error, str, 'Error', 'Icon', 'error');
                
                
                app.InputcycleinformationButton.Enable='on';
                app.Step1CheckFocusingButton.Enable='on';
                app.Step2CheckAlignmentButton.Enable='on';
                app.CreateTilesButton.Enable='on';
                app.GenerateMaxProjectionButton.Enable='on';
                
                error('Error: Remote and local file numbers do not match, please manually check files!');
             end 
        end
 function CreateTilesButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
          
            app.experiment_id=char(app.ExperimentIDEditField.Value);
            path=fullfile(app.acquisition_root, app.experiment_id);
            cd(path)
            app.MessageTextArea.Value='';
            app.WarningTextArea.Value='';
            cycletype=char(app.CycletypeDropDown.Value);
            cyclenum=app.Cycle_numSpinner_3.Value;
            cycle_name=[cycletype,num2str(cyclenum,'%.2u')];
            pixelsize=str2double(app.pixelsizeEditField.Value);
            niecreatetilesuneven(['regoffset',cycle_name,'.csv'],3200,pixelsize,20);
            filename=append('tiledregoffset',cycle_name,'.csv');
            tiledreoffset=readtable(filename);
            row=height(tiledreoffset);
            app.MessageTextArea.Value{1}=sprintf('Tiled position list saved to %s\n',['tiledregoffset',cycle_name,'.csv']);
            app.MessageTextArea.Value{2}=sprintf('Position information saved to %s\n',['Posinfo_regoffset',cycle_name,'.mat']);
            app.MessageTextArea.Value{3}='Checking if there is enough space for current cycle...';
            
            acquisition_avail_space=getFreeSpace(app.acquisition_root);
            maxproj_avail_space=getFreeSpace(app.maxproj_root);
            % cmd=['for /f "tokens=4 delims= " %i in (''ssh ', app.remote_storage,' df ^| findstr md1'') DO @echo %i'];
            % [status,cmdout]=system(cmd);
            
            [acquisition_space_need,maxproj_space_need,archive_space_need]=CalculateNeedSpace(cycle_name,row);
            warn={};
            if acquisition_space_need>=acquisition_avail_space
               warn{end+1}=(['Path ',app.acquisition_root,' does not have enough space for current cycle!']);
            end
            if maxproj_space_need>=maxproj_avail_space
               warn{end+1}=(['Path ', app.maxproj_root,' does not have enough space for current cycle!']);
            end
            
            %if status==0
            %    archive_avail_space=str2double(cmdout)*1024;
            %    if archive_space_need>=archive_avail_space
            %       warn{end+1}=('Archive drive does not have enough space for current cycle!');
            %    end
            %else
            %    warn{end+1}='Error in accessing remote storage server!';
            %end
            
            TF = isempty(warn);
            if TF == 1
                app.WarningTextArea.Value='';
                app.MessageTextArea.Value{4}='All hard drives have enough space for current cycle!';
            elseif TF==0
                app.WarningTextArea.Value=sprintf('%s \n',warn{:});
                app.MessageTextArea.Value{4}='Check warning message!';
            end
            app.InputcycleinformationButton.Enable='on';
            app.Step1CheckFocusingButton.Enable='on';
            app.Step2CheckAlignmentButton.Enable='on';
            app.CreateTilesButton.Enable='on';
            app.GenerateMaxProjectionButton.Enable='on';
          
 end


 % Callback function: not associated with a component
        function CheckDeleteButtonPushed(app, event)
            app.remote_rootEditField.Enable = 'off';
            app.remote_loginEditField.Enable='off';
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
            app.experiment_id=char(app.DatafolderEditField_2.Value);
            cycletype=app.CycletypeDropDown_2.Value;
            cyclenum=app.Cycle_numSpinner_4.Value;
            cycle_name=[cycletype,num2str(cyclenum,'%.2u')];
            app.MessageTextArea.Value='Check the folder details';
          
            cd(app.Aws_management_dir);

            datafolderfull=fullfile(app.acquisition_drive,app.datafolder,cycle_name);
            filename=[app.datafolder,cycle_name,'.txt'];
            pause(2)
            cmd=append('aws s3 sync ',datafolderfull,' s3://barseqtest/',app.datafolder,'/',cycle_name,' --dryrun > ',filename);
            system(cmd);
            pause(2)
            app.MessageTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('Check AWS details')}];      
            t = readtable(filename,'ReadVariableNames',false);
          
            number=height(t);
            if number~=0
                app.WarningTextArea.FontColor=[1 0 0];
                app.WarningTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('Do not delete!,Missing files detected, details is saved in AWS Managemenr folder')}];
            else
                dict=fullfile(app.acquisition_drive,app.datafolder);
                cd(dict)
                app.MessageTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('All files are in AWS now, deleting the foldernow')}];
                rmdir(cycle_name, 's')
            end


        end

        % Callback function: not associated with a component
        function ResumeButtonPushed(app, event)
            app.datafolder=char(app.DatafolderEditField_2.Value);
            cycletype=app.CycletypeDropDown_2.Value;
            cyclenum=app.Cycle_numSpinner_4.Value;
            cycle_name=[cycletype,num2str(cyclenum,'%.2u')];
            app.WarningTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('Resume uploading to AWS')}];
            datafolderfull=fullfile(app.acquisition_drive,app.datafolder,cycle_name);
            cmd=append('start aws s3 sync ',datafolderfull,' s3://barseqtest/',app.datafolder,'/',cycle_name,' --storage-class DEEP_ARCHIVE');
            systme(cmd);
            app.WarningTextArea.Value=[app.MessageTextArea.Value(:)',{sprintf('Done')}];
        end
