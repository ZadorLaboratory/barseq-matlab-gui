classdef Imaging_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        MaxProjRootEditField           matlab.ui.control.EditField
        MaxProjRootEditFieldLabel      matlab.ui.control.Label
        AcquisitionRootEditField       matlab.ui.control.EditField
        AcquisitionRootEditFieldLabel  matlab.ui.control.Label
        ArchiveRemotelyButton          matlab.ui.control.Button
        ArchiveLocallyButton           matlab.ui.control.Button
        Section6ArchiveRemotelyLabel   matlab.ui.control.Label
        Section5ArchiveLocallyLabel    matlab.ui.control.Label
        SendtoAWSDropDown              matlab.ui.control.DropDown
        SendtoAWSDropDownLabel         matlab.ui.control.Label
        ChangepixeisizeCheckBox        matlab.ui.control.CheckBox
        ChangeCheckBox                 matlab.ui.control.CheckBox
        SlicePerSlideEditField         matlab.ui.control.EditField
        SlicePerSlideEditFieldLabel    matlab.ui.control.Label
        Section1ImagingSettingLabel_2  matlab.ui.control.Label
        Step2CheckAlignmentButton      matlab.ui.control.Button
        WarningTextAreaLabel_2         matlab.ui.control.Label
        WarningTextArea                matlab.ui.control.TextArea
        MessageTextAreaLabel_2         matlab.ui.control.Label
        MessageTextArea                matlab.ui.control.TextArea
        pixelsizeEditField             matlab.ui.control.EditField
        pixelsizeEditFieldLabel        matlab.ui.control.Label
        remote_rootEditField           matlab.ui.control.EditField
        remote_rootEditFieldLabel      matlab.ui.control.Label
        remote_loginEditField          matlab.ui.control.EditField
        remote_loginEditFieldLabel     matlab.ui.control.Label
        InputcycleinformationButton    matlab.ui.control.Button
        Cycle_numSpinner_3             matlab.ui.control.Spinner
        Cycle_numSpinner_3Label        matlab.ui.control.Label
        Section4MaxprojectionLabel     matlab.ui.control.Label
        Section3CreateTilesLabel       matlab.ui.control.Label
        Section2FocusingLabel          matlab.ui.control.Label
        CreateTilesButton              matlab.ui.control.Button
        GenerateMaxProjectionButton    matlab.ui.control.Button
        Step1CheckFocusingButton       matlab.ui.control.Button
        InitCycleTypeDropDown          matlab.ui.control.DropDown
        init_cycle_typeLabel           matlab.ui.control.Label
        CycletypeDropDown              matlab.ui.control.DropDown
        CycletypeDropDownLabel         matlab.ui.control.Label
        ExperimentIDEditField          matlab.ui.control.EditField
        ExperimentIDEditFieldLabel     matlab.ui.control.Label
        TechnicianDropDown             matlab.ui.control.DropDown
        TechnicianDropDownLabel        matlab.ui.control.Label
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes                         matlab.ui.control.UIAxes
    end

    properties (Access = private)
        acquisition_root = 'D:/barseq'; % Root of path for acquisition
        maxproj_root = 'D:/maxproj'; % Root of path for storing max projections
        acquisition_path = ''; % Full path for acquisition
        maxproj_path = ''; % Full path for storing max projections        
        experiment_id=''; % Folder in which the experiment is stored under root path(s).
        maxproj_folder=''; % Remote der storing the maxprojection files
        remote_root = '/grid/mbseq/data_norepl/barseq/raw_data';
        remote_storage = [];  %'imagestorage@barseqstorage0'; % Remote storage server, in the format of username@servername
        person="Diana Ravens"; % The person running the experiment
        aws_management_dir=[];%'C:/Users/Chen Lab CREST/Desktop/AWS_Management'; % Local working folder for managing AWS transfer    
        phonebook=["Diana Ravens","1234567890","tmobile"];
        pausetime=50
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: InputcycleinformationButton
        function InputcycleinformationButtonPushed(app, event)
            app.experiment_id=char(app.ExperimentIDEditField.Value);
            app.MessageTextArea.Value='';
            app.WarningTextArea.Value='';
            cycletype=char(app.CycletypeDropDown.Value);
            app.person=char(app.TechnicianDropDown.Value);
            cyclenum=app.Cycle_numSpinner_3.Value;
            app.acquisition_root = app.AcquisitionRootEditField.Value
            app.maxproj_root = app.MaxProjRootEditField.Value ; 
            app.acquisition_path =   fullfile(app.AcquisitionRootEditField.Value , app.ExperimentIDEditField.Value);
            app.maxproj_path= fullfile(app.MaxProjRootEditField.Value , app.ExperimentIDEditField.Value);
            
            if ~exist(app.acquisition_path,'dir')
               mkdir(app.acquisition_path)
               app.MessageTextArea.Value{1}=['Data folder:', app.acquisition_path,' created.'];
            else
               app.WarningTextArea.Value=['Folder: ',app.acquisition_path, ' already exists! First cycle?'];
               app.WarningTextArea.FontColor=[1 0 0];
               app.MessageTextArea.Value{1}='';
            end 
         
            app.MessageTextArea.Value{2}=['Please confirm experiment folder:',app.acquisition_path];
            app.MessageTextArea.Value{3}=['Please confirm cycle name: ',[cycletype,num2str(cyclenum,'%.2u')]];
            app.MessageTextArea.Value{4}=['Please confirm technician who is running the experiment: ',app.person];
            cd( app.acquisition_path )
        end

        % Button pushed function: Step1CheckFocusingButton
        function Step1CheckFocusingButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
            app.ArchiveLocallyButton.Enable = 'off';
            app.ArchiveRemotelyButton.Enable = 'off';


            path=app.acquisition_path;
            cd(path);
            app.MessageTextArea.Value='';
            app.WarningTextArea.Value='';
            f = waitbar(0,'Please wait...');
            cycletype=char(app.CycletypeDropDown.Value);
            cyclenum=app.Cycle_numSpinner_3.Value;
            cycle_name=[cycletype, num2str(cyclenum,'%.2u')];
            app.MessageTextArea.Value=['Calculating focus for ',[cycle_name,'.csv'],'...'];
            pos_per_slice=4; % don't change this
            focus_folder=['focus', cycle_name]; % e.g. focus + geneseq + 00 +
            dicch=2;
            focusch=1;
            waitbar(.33,f,'processing your data');
            try
                offset=niefindfluorfocusfast1([cycle_name,'.csv'], focus_folder, -30, 30, 1.5, focusch,dicch);
                waitbar(.66,f,'plotting your data');
                plot(app.UIAxes,offset,'-k','LineWidth',1);
                hold(app.UIAxes, 'on');
                plot(app.UIAxes,[1 numel(offset)],[20 20],'--r','LineWidth',1);
                plot(app.UIAxes,[1 numel(offset)],[-20 -20],'--r','LineWidth',1);
                hold(app.UIAxes, 'off');
                app.UIAxes.XLim=[1 numel(offset)];
                app.UIAxes.YLim=[-30 30];
                xlabel(app.UIAxes,'Positions')
                ylabel(app.UIAxes,'Focus shift');

                waitbar(1,f,'Done!');
                close(f)
                app.MessageTextArea.Value= ['Done! Focused positions saved to ',['offset',cycle_name,'.csv']];
                I=abs(offset)>20;
                if sum(I)>0
                    app.WarningTextArea.Value='Please check the following positions with extreme shifts:';
                    app.WarningTextArea.FontColor=[1 0 0];
                    idx=find(I);
                    app.MessageTextArea.Value=sprintf('Position %d: Shift %d\n',[idx,round(offset(idx))]');
                else
                    app.MessageTextArea.Value= 'All points appear to focus fine.';
                end
               
           catch ME % ME is of the class MException (in-built Matlab)
                str = sprintf(['Something is wrong with input files or setting. \n' 'Matlab says: \n' ME.message]);
                f_error = app.UIFigure;
                f_error.WindowStyle = 'modal';
                uialert(f_error, str, 'Input Files or Setting Error', 'Icon', 'error');
                close(f);
            end          
            app.InputcycleinformationButton.Enable='on';
            app.Step1CheckFocusingButton.Enable='on';
            app.Step2CheckAlignmentButton.Enable='on';
            app.CreateTilesButton.Enable='on';
            app.GenerateMaxProjectionButton.Enable='on';
            app.ArchiveLocallyButton.Enable = 'on';
            app.ArchiveRemotelyButton.Enable = 'on'; 
        end

        % Button pushed function: Step2CheckAlignmentButton
        function Step2CheckAlignmentButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
            app.ArchiveLocallyButton.Enable = 'off';
            app.ArchiveRemotelyButton.Enable = 'off';
                        
            path=app.acquisition_path
            cd(path) 
         
            app.WarningTextArea.Value='';
            app.MessageTextArea.Value='';
            f = waitbar(0,'Please wait...');
            app.MessageTextArea.Value='Registering xy position using DIC image...';
            cycletype=char(app.CycletypeDropDown.Value);
            cyclenum=app.Cycle_numSpinner_3.Value;
            cycle_name=[cycletype,num2str(cyclenum,'%.2u')];
            focus_folder=['focus', cycle_name];
            pixelsize=str2double(app.pixelsizeEditField.Value);
            init_cycle=[char(app.InitCycleTypeDropDown.Value),'00'];
            str=app.SlicePerSlideEditField.Value;
            tmp = regexp(str,'([^ ,:]*)','tokens');
            out = cat(2,tmp{:});
            slice_per_slide_1=str2double(out);
            waitbar(.33,f,'processing your data');
            try
                xy_translation=niematchdicxy1_gui(app, ['offset', cycle_name,'.csv'],['dic',focus_folder],['dicfocus',init_cycle],pixelsize,slice_per_slide_1,0);
                waitbar(1,f,'Done!');
                close(f);
                app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {'Done!'}];
                app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', { sprintf('Pos %u, x =  %d, y = %d\n',[(1:size(xy_translation,1)); int16(round(xy_translation))'])}];
             
                scatter(app.UIAxes2,xy_translation(:,1)',xy_translation(:,2)',10,1:size(xy_translation,1),'filled');
                app.UIAxes2.XLim=[min(xy_translation(:,1))-5, max(xy_translation(:,1))+5];
                app.UIAxes2.YLim=[min(xy_translation(:,2))-5, max(xy_translation(:,2))+5] ;
                xlabel(app.UIAxes2,'X shift (pixels)');
                ylabel(app.UIAxes2,'Y shift(pixels)');
            
            catch ME % ME is of the class MException (in-built Matlab)
                str = sprintf(['Something is wrong with input files or setting. \n' 'Matlab says: \n' ME.message]);
                f_error = app.UIFigure;
                f_error.WindowStyle = 'modal';
                uialert(f_error, str, 'Input Files or Setting Error', 'Icon', 'error');
                close(f);                
            end
            app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {'Done!'}];
            
            app.InputcycleinformationButton.Enable='on';
            app.Step1CheckFocusingButton.Enable='on';
            app.Step2CheckAlignmentButton.Enable='on';
            app.CreateTilesButton.Enable='on';
            app.GenerateMaxProjectionButton.Enable='on';
            app.ArchiveLocallyButton.Enable = 'on';
            app.ArchiveRemotelyButton.Enable = 'on'; 
        end

        % Button pushed function: CreateTilesButton
        function CreateTilesButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
            app.ArchiveLocallyButton.Enable = 'off';
            app.ArchiveRemotelyButton.Enable = 'off'; 

            app.experiment_id=char(app.ExperimentIDEditField.Value);
            path=app.acquisition_path;
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
            mess = [sprintf('Tiled position list saved to %s\n',['tiledregoffset',cycle_name,'.csv'])];
            app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', { mess }];

            mess = [sprintf('Tiled position list saved to %s\n',['tiledregoffset',cycle_name,'.csv'])];
            app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', { mess }];

            %app.MessageTextArea.Value{1}=sprintf('Tiled position list saved to %s\n',['tiledregoffset',cycle_name,'.csv']);
            %app.MessageTextArea.Value{2}=sprintf('Position information saved to %s\n',['Posinfo_regoffset',cycle_name,'.mat']);
            %app.MessageTextArea.Value{3}='Checking if there is enough space for current cycle...';
            
            %acquisition_avail_space=getFreeSpace(app.acquisition_root);
            %maxproj_avail_space=getFreeSpace(app.maxproj_root);
            % cmd=['for /f "tokens=4 delims= " %i in (''ssh ', app.remote_storage,' df ^| findstr md1'') DO @echo %i'];
            % [status,cmdout]=system(cmd);
            
            %[acquisition_space_need, maxproj_space_need, archive_space_need]=CalculateNeedSpace(cycle_name,row);
            %warn={};
            %if acquisition_space_need>=acquisition_avail_space
            %   warn{end+1}=(['Path ',app.acquisition_root,' does not have enough space for current cycle!']);
            %end
            %if maxproj_space_need>=maxproj_avail_space
            %   warn{end+1}=(['Path ', app.maxproj_root,' does not have enough space for current cycle!']);
            %end
            
            %TF = isempty(warn);
            %if TF == 1
            %    app.WarningTextArea.Value='';
            %    app.MessageTextArea.Value{4}='All hard drives have enough space for current cycle!';
            %elseif TF==0
            %    app.WarningTextArea.Value=sprintf('%s \n',warn{:});
            %    app.MessageTextArea.Value{4}='Check warning message!';
            %end
            app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', { 'Done' }];
            
            % app.MessageTextArea.Value{5}='Done!';
            app.InputcycleinformationButton.Enable='on';
            app.Step1CheckFocusingButton.Enable='on';
            app.Step2CheckAlignmentButton.Enable='on';
            app.CreateTilesButton.Enable='on';
            app.GenerateMaxProjectionButton.Enable='on';
            app.ArchiveLocallyButton.Enable = 'on';
            app.ArchiveRemotelyButton.Enable = 'on'; 
          
        end

        % Button pushed function: GenerateMaxProjectionButton
        function GenerateMaxProjectionButtonPushed(app, event)
            app.InputcycleinformationButton.Enable='off';
            app.Step1CheckFocusingButton.Enable='off';
            app.Step2CheckAlignmentButton.Enable='off';
            app.CreateTilesButton.Enable='off';
            app.GenerateMaxProjectionButton.Enable='off';
            app.ArchiveLocallyButton.Enable = 'off';
            app.ArchiveRemotelyButton.Enable = 'off';
       
            app.experiment_id=char(app.ExperimentIDEditField.Value);
            path=fullfile(app.acquisition_root, app.experiment_id);
            cd(path)
            app.MessageTextArea.Value=sprintf('Max projection path=%s ', path );

            
            load('tformsingle.mat','tformsingle');
            %app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', {'Loaded tformsingle.mat ...'} ];            
            app.MessageTextArea.Value=sprintf('Loaded tformsingle.mat ...');

            try
                cycle_type=app.CycletypeDropDown.Value;
                cycle_num=app.Cycle_numSpinner_3.Value;
                cycle_name=[cycle_type, num2str(cycle_num,'%.2u')];
                app.experiment_id=char(app.ExperimentIDEditField.Value);
            
                %app.MessageTextArea.Value=[app.MessageTextArea.Value(:)', { 'Initializing. cycle_name=', cycle_name , ' cyclenum=', cyclenum , ' cycle_type= ', cycle_type  }];
                app.MessageTextArea.Value=sprintf(['Initializing. cycle_name=', cycle_name , ' cycle_num=', cycle_num , ' cycle_type= ', cycle_type ]);

                ch_seq=[2 1 3 4 5]; tformch=[];
                switch cycle_type
                    case 'geneseq'
                        tform=tformsingle;
                        if cycle_num==1
                            ch_seq=[2 1 3 4 5]; tformch=[]; %single-seq
                        elseif cycle_num>1
                            ch_seq=[2 1 3 4]; tformch=[]; %single-seq
                        end
                    case 'bcseq'
                        tform=tformsingle;
                        if cycle_num==1
                            ch_seq=[2 1 3 4 5]; tformch=[]; %single-seq
                        else
                            ch_seq=[2 1 3 4]; tformch=[]; %single-seq
                        end
                    case 'hyb'
                        tform=tformsingle;
                        ch_seq=[1 5 2 6 3 4]; tformch=[]; %hyb using C1
                end
                app.MessageTextArea.Value=sprintf(['ch_seq=', ch_seq ]);

                f = waitbar(0,'Initializing max projection...');
                waitbar(.15,f,'Starting max projection');
                %app.MessageTextArea.Value=[ app.MessageTextArea.Value(:)', { sprintf('Starting max projection on cycle %s ', [cycle_type, num2str(cycle_num,'%.2u')] ) } ];
                app.MessageTextArea.Value=sprintf('Starting max projection on cycle %s ', [cycle_type, num2str(cycle_num,'%.2u')] );            
                %app.MessageTextArea.Value=[app.MessageTextArea.Value(:), {'Calling niemaxprojimaging_gui( cycle_name=', cycle_name , ' acq_root= ', app.acquisition_root, ' maxproj_root= ', app.maxproj_root } ];
                
                srcdir = fullfile(app.acquisition_root, app.experiment_id, cycle_name);
                destdir = fullfile(app.maxproj_root, app.experiment_id)
                app.MessageTextArea.Value=['Calling niemaxprojimaging_gui( cycle_name=', cycle_name , ' acq_root= ', app.acquisition_root, ...
                ' maxproj_root= ', app.maxproj_root, ' src_dir=', srcdir, ' dest_dir=',destdir];
                % new signature?
                % niemaxprojimaging_gui(app, cyclename, chseq, tformch, pausetime, posinfo, tform, srcpath, destpath)
                % new call:
                % niemaxprojimaging_gui(app, cycle_name, ch_seq, tformch, app.pausetime, ['Posinfo_regoffset', cycle_name,'.mat'], ...
                % tform, ...
                % srcdir, destdir );
                %
                % old signature
                % niemaxprojimaging_gui(app, foldername, chseq, tformch, pausetime, posinfo, tform, localpath)
                niemaxprojimaging_gui(app, cycle_name, ch_seq, tformch, app.pausetime, ['Posinfo_regoffset', cycle_name,'.mat'], tform, destdir );

                app.MessageTextArea.Value=sprintf('Maxprojection Done!');

            catch ME % ME is of the class MException (in-built Matlab)
                str = sprintf(['Something is wrong with input files or setting. \n' 'Matlab says: \n' ME.message]);
                f_error = app.UIFigure;
                f_error.WindowStyle = 'modal';
                uialert(f_error, str, 'Input Files or Setting Error', 'Icon', 'error');
                close(f);
            end          
            
            
            app.InputcycleinformationButton.Enable='on';
            app.Step1CheckFocusingButton.Enable='on';
            app.Step2CheckAlignmentButton.Enable='on';
            app.CreateTilesButton.Enable='on';
            app.GenerateMaxProjectionButton.Enable='on';
            app.ArchiveLocallyButton.Enable = 'on';
            app.ArchiveRemotelyButton.Enable = 'on'; 
        end

        % Value changed function: MessageTextArea
        function MessageTextAreaValueChanged(app, event)
            drawnow;
        end

        % Value changed function: WarningTextArea
        function WarningTextAreaValueChanged(app, event)
            drawnow;
            
        end

        % Callback function: ChangeCheckBox, TechnicianDropDown
        function ChangeCheckBoxValueChanged(app, event)
            value = app.ChangeCheckBox.Value;
            if value
               app.remote_rootEditField.Enable = 'on';
               app.remote_rootEditFieldLabel.Enable='on';
              
            else
               app.remote_rootEditField.Enable = 'off';
               app.remote_loginEditField.Enable='off';
           

            end
        end

        % Value changed function: ChangepixeisizeCheckBox
        function ChangepixeisizeCheckBoxValueChanged(app, event)
            value = app.ChangepixeisizeCheckBox.Value;
            if value
              app.pixelsizeEditField.Enable='on';
              app.pixelsizeEditFieldLabel.Enable='on'; 
            else
               app.pixelsizeEditField.Enable= 'off';
               app.pixelsizeEditFieldLabel.Enable='off';
            end
        end

        % Value changed function: TechnicianDropDown
        function TechnicianDropDownValueChanged(app, event)
            value = app.TechnicianDropDown.Value;
            
        end

        % Value changed function: Cycle_numSpinner_3
        function Cycle_numSpinner_3ValueChanged(app, event)
            value = app.Cycle_numSpinner_3.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 967 740];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [32 168 403 289];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [507 168 421 289];

            % Create TechnicianDropDownLabel
            app.TechnicianDropDownLabel = uilabel(app.UIFigure);
            app.TechnicianDropDownLabel.HorizontalAlignment = 'right';
            app.TechnicianDropDownLabel.Position = [25 672 62 22];
            app.TechnicianDropDownLabel.Text = 'Technician';

            % Create TechnicianDropDown
            app.TechnicianDropDown = uidropdown(app.UIFigure);
            app.TechnicianDropDown.Items = {'Diana Ravens'};
            app.TechnicianDropDown.DropDownOpeningFcn = createCallbackFcn(app, @ChangeCheckBoxValueChanged, true);
            app.TechnicianDropDown.ValueChangedFcn = createCallbackFcn(app, @TechnicianDropDownValueChanged, true);
            app.TechnicianDropDown.Position = [101 672 108 22];
            app.TechnicianDropDown.Value = 'Diana Ravens';

            % Create ExperimentIDEditFieldLabel
            app.ExperimentIDEditFieldLabel = uilabel(app.UIFigure);
            app.ExperimentIDEditFieldLabel.HorizontalAlignment = 'right';
            app.ExperimentIDEditFieldLabel.Position = [244 671 81 22];
            app.ExperimentIDEditFieldLabel.Text = 'Experiment ID';

            % Create ExperimentIDEditField
            app.ExperimentIDEditField = uieditfield(app.UIFigure, 'text');
            app.ExperimentIDEditField.Position = [350 671 119 22];

            % Create CycletypeDropDownLabel
            app.CycletypeDropDownLabel = uilabel(app.UIFigure);
            app.CycletypeDropDownLabel.HorizontalAlignment = 'right';
            app.CycletypeDropDownLabel.Position = [25 620 58 22];
            app.CycletypeDropDownLabel.Text = 'Cycletype';

            % Create CycletypeDropDown
            app.CycletypeDropDown = uidropdown(app.UIFigure);
            app.CycletypeDropDown.Items = {'geneseq', 'hyb', 'bcseq'};
            app.CycletypeDropDown.Position = [105 620 100 22];
            app.CycletypeDropDown.Value = 'geneseq';

            % Create init_cycle_typeLabel
            app.init_cycle_typeLabel = uilabel(app.UIFigure);
            app.init_cycle_typeLabel.HorizontalAlignment = 'right';
            app.init_cycle_typeLabel.Position = [246 620 77 22];
            app.init_cycle_typeLabel.Text = 'InitCycleType';

            % Create InitCycleTypeDropDown
            app.InitCycleTypeDropDown = uidropdown(app.UIFigure);
            app.InitCycleTypeDropDown.Items = {'geneseq', 'hyb', 'bc_seq'};
            app.InitCycleTypeDropDown.Position = [350 620 119 22];
            app.InitCycleTypeDropDown.Value = 'geneseq';

            % Create Step1CheckFocusingButton
            app.Step1CheckFocusingButton = uibutton(app.UIFigure, 'push');
            app.Step1CheckFocusingButton.ButtonPushedFcn = createCallbackFcn(app, @Step1CheckFocusingButtonPushed, true);
            app.Step1CheckFocusingButton.FontWeight = 'bold';
            app.Step1CheckFocusingButton.Position = [177 468 144 22];
            app.Step1CheckFocusingButton.Text = 'Step1 Check Focusing';

            % Create GenerateMaxProjectionButton
            app.GenerateMaxProjectionButton = uibutton(app.UIFigure, 'push');
            app.GenerateMaxProjectionButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateMaxProjectionButtonPushed, true);
            app.GenerateMaxProjectionButton.FontWeight = 'bold';
            app.GenerateMaxProjectionButton.Position = [330 95 160 23];
            app.GenerateMaxProjectionButton.Text = 'Generate Max Projection';

            % Create CreateTilesButton
            app.CreateTilesButton = uibutton(app.UIFigure, 'push');
            app.CreateTilesButton.ButtonPushedFcn = createCallbackFcn(app, @CreateTilesButtonPushed, true);
            app.CreateTilesButton.FontWeight = 'bold';
            app.CreateTilesButton.Position = [330 125 159 23];
            app.CreateTilesButton.Text = 'Create Tiles';

            % Create Section2FocusingLabel
            app.Section2FocusingLabel = uilabel(app.UIFigure);
            app.Section2FocusingLabel.FontWeight = 'bold';
            app.Section2FocusingLabel.Position = [26 468 116 22];
            app.Section2FocusingLabel.Text = 'Section 2 Focusing';

            % Create Section3CreateTilesLabel
            app.Section3CreateTilesLabel = uilabel(app.UIFigure);
            app.Section3CreateTilesLabel.FontWeight = 'bold';
            app.Section3CreateTilesLabel.Position = [26 125 300 24];
            app.Section3CreateTilesLabel.Text = 'Section 3 Create Tiles';

            % Create Section4MaxprojectionLabel
            app.Section4MaxprojectionLabel = uilabel(app.UIFigure);
            app.Section4MaxprojectionLabel.FontWeight = 'bold';
            app.Section4MaxprojectionLabel.Position = [27 95 162 22];
            app.Section4MaxprojectionLabel.Text = 'Section 4 Maxprojection';

            % Create Cycle_numSpinner_3Label
            app.Cycle_numSpinner_3Label = uilabel(app.UIFigure);
            app.Cycle_numSpinner_3Label.HorizontalAlignment = 'right';
            app.Cycle_numSpinner_3Label.Position = [25 585 66 22];
            app.Cycle_numSpinner_3Label.Text = 'Cycle_num';

            % Create Cycle_numSpinner_3
            app.Cycle_numSpinner_3 = uispinner(app.UIFigure);
            app.Cycle_numSpinner_3.Limits = [0 32];
            app.Cycle_numSpinner_3.ValueChangedFcn = createCallbackFcn(app, @Cycle_numSpinner_3ValueChanged, true);
            app.Cycle_numSpinner_3.HorizontalAlignment = 'left';
            app.Cycle_numSpinner_3.Position = [106 585 100 22];

            % Create InputcycleinformationButton
            app.InputcycleinformationButton = uibutton(app.UIFigure, 'push');
            app.InputcycleinformationButton.ButtonPushedFcn = createCallbackFcn(app, @InputcycleinformationButtonPushed, true);
            app.InputcycleinformationButton.FontWeight = 'bold';
            app.InputcycleinformationButton.Position = [178 510 148 22];
            app.InputcycleinformationButton.Text = 'Input cycle information';

            % Create remote_loginEditFieldLabel
            app.remote_loginEditFieldLabel = uilabel(app.UIFigure);
            app.remote_loginEditFieldLabel.HorizontalAlignment = 'right';
            app.remote_loginEditFieldLabel.Enable = 'off';
            app.remote_loginEditFieldLabel.Position = [559 125 74 22];
            app.remote_loginEditFieldLabel.Text = 'remote_login';

            % Create remote_loginEditField
            app.remote_loginEditField = uieditfield(app.UIFigure, 'text');
            app.remote_loginEditField.Enable = 'off';
            app.remote_loginEditField.Position = [643 125 100 22];
            app.remote_loginEditField.Value = 'user@bamdev1';

            % Create remote_rootEditFieldLabel
            app.remote_rootEditFieldLabel = uilabel(app.UIFigure);
            app.remote_rootEditFieldLabel.HorizontalAlignment = 'right';
            app.remote_rootEditFieldLabel.Enable = 'off';
            app.remote_rootEditFieldLabel.Position = [542 95 85 22];
            app.remote_rootEditFieldLabel.Text = 'remote_root';

            % Create remote_rootEditField
            app.remote_rootEditField = uieditfield(app.UIFigure, 'text');
            app.remote_rootEditField.Enable = 'off';
            app.remote_rootEditField.Position = [647 95 271 22];
            app.remote_rootEditField.Value = '/grid/mbseq/data_norepl/barseq/raw_data';

            % Create pixelsizeEditFieldLabel
            app.pixelsizeEditFieldLabel = uilabel(app.UIFigure);
            app.pixelsizeEditFieldLabel.HorizontalAlignment = 'right';
            app.pixelsizeEditFieldLabel.Enable = 'off';
            app.pixelsizeEditFieldLabel.Position = [38 552 52 22];
            app.pixelsizeEditFieldLabel.Text = 'pixelsize';

            % Create pixelsizeEditField
            app.pixelsizeEditField = uieditfield(app.UIFigure, 'text');
            app.pixelsizeEditField.Enable = 'off';
            app.pixelsizeEditField.Position = [113 552 39 22];
            app.pixelsizeEditField.Value = '0.33';

            % Create MessageTextArea
            app.MessageTextArea = uitextarea(app.UIFigure);
            app.MessageTextArea.ValueChangedFcn = createCallbackFcn(app, @MessageTextAreaValueChanged, true);
            app.MessageTextArea.Position = [488 515 457 134];

            % Create MessageTextAreaLabel_2
            app.MessageTextAreaLabel_2 = uilabel(app.UIFigure);
            app.MessageTextAreaLabel_2.HorizontalAlignment = 'right';
            app.MessageTextAreaLabel_2.FontWeight = 'bold';
            app.MessageTextAreaLabel_2.Position = [689 651 56 22];
            app.MessageTextAreaLabel_2.Text = 'Message';

            % Create WarningTextArea
            app.WarningTextArea = uitextarea(app.UIFigure);
            app.WarningTextArea.ValueChangedFcn = createCallbackFcn(app, @WarningTextAreaValueChanged, true);
            app.WarningTextArea.Position = [489 671 456 40];

            % Create WarningTextAreaLabel_2
            app.WarningTextAreaLabel_2 = uilabel(app.UIFigure);
            app.WarningTextAreaLabel_2.HorizontalAlignment = 'right';
            app.WarningTextAreaLabel_2.FontWeight = 'bold';
            app.WarningTextAreaLabel_2.Position = [690 711 53 22];
            app.WarningTextAreaLabel_2.Text = 'Warning';

            % Create Step2CheckAlignmentButton
            app.Step2CheckAlignmentButton = uibutton(app.UIFigure, 'push');
            app.Step2CheckAlignmentButton.ButtonPushedFcn = createCallbackFcn(app, @Step2CheckAlignmentButtonPushed, true);
            app.Step2CheckAlignmentButton.FontWeight = 'bold';
            app.Step2CheckAlignmentButton.Position = [644 468 149 22];
            app.Step2CheckAlignmentButton.Text = 'Step2 Check Alignment';

            % Create Section1ImagingSettingLabel_2
            app.Section1ImagingSettingLabel_2 = uilabel(app.UIFigure);
            app.Section1ImagingSettingLabel_2.FontWeight = 'bold';
            app.Section1ImagingSettingLabel_2.Position = [26 711 152 22];
            app.Section1ImagingSettingLabel_2.Text = 'Section 1 Imaging Setting';

            % Create SlicePerSlideEditFieldLabel
            app.SlicePerSlideEditFieldLabel = uilabel(app.UIFigure);
            app.SlicePerSlideEditFieldLabel.HorizontalAlignment = 'right';
            app.SlicePerSlideEditFieldLabel.Position = [249 590 83 22];
            app.SlicePerSlideEditFieldLabel.Text = 'Slice Per Slide';

            % Create SlicePerSlideEditField
            app.SlicePerSlideEditField = uieditfield(app.UIFigure, 'text');
            app.SlicePerSlideEditField.Position = [350 590 62 22];

            % Create ChangeCheckBox
            app.ChangeCheckBox = uicheckbox(app.UIFigure);
            app.ChangeCheckBox.ValueChangedFcn = createCallbackFcn(app, @ChangeCheckBoxValueChanged, true);
            app.ChangeCheckBox.Text = {'Change'; ''};
            app.ChangeCheckBox.Position = [560 64 64 22];

            % Create ChangepixeisizeCheckBox
            app.ChangepixeisizeCheckBox = uicheckbox(app.UIFigure);
            app.ChangepixeisizeCheckBox.ValueChangedFcn = createCallbackFcn(app, @ChangepixeisizeCheckBoxValueChanged, true);
            app.ChangepixeisizeCheckBox.Text = 'Change pixeisize';
            app.ChangepixeisizeCheckBox.Position = [159 552 114 22];

            % Create SendtoAWSDropDownLabel
            app.SendtoAWSDropDownLabel = uilabel(app.UIFigure);
            app.SendtoAWSDropDownLabel.HorizontalAlignment = 'right';
            app.SendtoAWSDropDownLabel.Position = [550 30 88 22];
            app.SendtoAWSDropDownLabel.Text = 'Send to AWS';

            % Create SendtoAWSDropDown
            app.SendtoAWSDropDown = uidropdown(app.UIFigure);
            app.SendtoAWSDropDown.Items = {'No', 'Yes', ''};
            app.SendtoAWSDropDown.Position = [668 30 86 22];
            app.SendtoAWSDropDown.Value = 'No';

            % Create Section5ArchiveLocallyLabel
            app.Section5ArchiveLocallyLabel = uilabel(app.UIFigure);
            app.Section5ArchiveLocallyLabel.FontWeight = 'bold';
            app.Section5ArchiveLocallyLabel.Position = [27 64 162 22];
            app.Section5ArchiveLocallyLabel.Text = 'Section 5 Archive Locally';

            % Create Section6ArchiveRemotelyLabel
            app.Section6ArchiveRemotelyLabel = uilabel(app.UIFigure);
            app.Section6ArchiveRemotelyLabel.FontWeight = 'bold';
            app.Section6ArchiveRemotelyLabel.Position = [27 30 163 22];
            app.Section6ArchiveRemotelyLabel.Text = 'Section 6 Archive Remotely';

            % Create ArchiveLocallyButton
            app.ArchiveLocallyButton = uibutton(app.UIFigure, 'push');
            app.ArchiveLocallyButton.FontWeight = 'bold';
            app.ArchiveLocallyButton.Position = [330 64 160 23];
            app.ArchiveLocallyButton.Text = 'Archive Locally';

            % Create ArchiveRemotelyButton
            app.ArchiveRemotelyButton = uibutton(app.UIFigure, 'push');
            app.ArchiveRemotelyButton.FontWeight = 'bold';
            app.ArchiveRemotelyButton.Position = [331 30 160 23];
            app.ArchiveRemotelyButton.Text = 'Archive Remotely';

            % Create AcquisitionRootEditFieldLabel
            app.AcquisitionRootEditFieldLabel = uilabel(app.UIFigure);
            app.AcquisitionRootEditFieldLabel.HorizontalAlignment = 'right';
            app.AcquisitionRootEditFieldLabel.Position = [25 648 93 22];
            app.AcquisitionRootEditFieldLabel.Text = 'Acquisition Root';

            % Create AcquisitionRootEditField
            app.AcquisitionRootEditField = uieditfield(app.UIFigure, 'text');
            app.AcquisitionRootEditField.Position = [125 648 105 20];

            % Create MaxProjRootEditFieldLabel
            app.MaxProjRootEditFieldLabel = uilabel(app.UIFigure);
            app.MaxProjRootEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxProjRootEditFieldLabel.Position = [246 647 78 22];
            app.MaxProjRootEditFieldLabel.Text = 'MaxProj Root';

            % Create MaxProjRootEditField
            app.MaxProjRootEditField = uieditfield(app.UIFigure, 'text');
            app.MaxProjRootEditField.Position = [350 647 119 21];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Imaging_GUI

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end