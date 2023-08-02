function xy_translation=niematchdicxy1_gui(app, posfname, dicfolder, firstdicfolder, pixelsize_um, slice_per_slide, checkimage)
    % given a list of positions and a z-stack of dic images, calculate
    % difference with the first cycle.

    % slice_per_slide=2;
    % firstdicfolder='genedic01';
    % dicfolder=['genedic07'];
    % posfname=''; % position list filename.
    % pixelsize_um=0.32;
    %%
    if ~exist('checkimage','var')
        checkimage=0;%whether to check image after registration
    end

    if isempty(firstdicfolder)
        firstdicfolder='genedic01';
    end


    pixelsize=pixelsize_um/1000; %20x pixel size in um (the stage records positions in um)
    stage_x_dir=-1; %-1: left is larger
    stage_y_dir=1; %1: bottom is larger
    pos_per_slice=4; % don't change this
    pos_batch_size=slice_per_slide*pos_per_slice;% this controls how many positions to pool, usually all positions from a slide

    %tic
    % read all images
    imref={};
    imcurr={};
    fname1=dir([firstdicfolder,'/*.tif']);
    fname1=sort_nat({fname1.name});
    parfor i=1:numel(fname1)
        imref{i}=imread([firstdicfolder,'/',fname1{i}]);
    end

    fname2=dir([dicfolder,'/*.tif']);
    fname2=sort_nat({fname2.name});
    parfor i=1:numel(fname2)
        imcurr{i}=imread([dicfolder,'/',fname2{i}]);
    end
    app.MessageTextArea.Value= ['firstdicfolder=', firstdicfolder, ' dicfolder= ', dicfolder  ];

    if numel(imref)~=numel(imcurr)
        app.WarningTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf('The number of images is different from the first cycle. Abort.')}];
        app.WarningTextArea.FontColor=[1 0 0];
        error('The number of images is different from the first cycle. Abort.')
    end
    %toc

    %make slidenum. If only a single slice_per_slide is provided, assume same
    %number of slices per slide. If slice_per_slide is a vector, then use
    %indiviudal values for different slides.
    if numel(slice_per_slide)==1
        slidenum=ceil((1:numel(imref))/pos_batch_size);
    else
        slidenum=zeros(sum(pos_batch_size),1);
        slidenum(1:pos_batch_size(1))=1;
    
        for i=2:numel(pos_batch_size)
            slidenum(sum(pos_batch_size(1:i-1))+1:sum(pos_batch_size(1:i)))=i;
        end
    end

    %check to make sure 1 slide num per position
    if numel(slidenum)~=numel(imcurr)
        %imcurr
        %slidenum
        %pos_batch_size
        app.WarningTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf('The number of images is different from slice numbers. Abort.')}];
        app.WarningTextArea.FontColor=[1 0 0];
        error('The number of images is different from slice numbers. Abort.')
    end

    %%
    %align using imregtform or imregcorr
    %[optimizer,metric] = imregconfig('multimodal');
    %optimizer.InitialRadius = optimizer.InitialRadius/5; %trial 1 conditions
    %optimizer.MaximumIterations=optimizer.MaximumIterations*5;

    tform={};
    xy_translation=zeros(numel(imref),2);
    %tic
    parfor i=1:numel(imref)
        tform{i}=imregcorr(imcurr{i}(200:end-200,200:end-200), imref{i}(200:end-200,200:end-200), 'translation')
        xy_translation(i,:)=[tform{i}.T(3,1),tform{i}.T(3,2)];
    end
    %toc
    %%
    xy_translation_pooled=xy_translation;

    uniqslidenum=unique(slidenum);
    for i=1:numel(uniqslidenum)
        xy=median(xy_translation(slidenum==uniqslidenum(i),:),1);
        xy_translation_pooled(slidenum==uniqslidenum(i),:)=repmat(xy,sum(slidenum==uniqslidenum(i)),1);
    end

    Rfixed=imref2d(size(imref{i}));

    %% warning if overall correction is too large or there are spurious values
    for i=1:numel(uniqslidenum)
        xy_translation_sub=xy_translation(slidenum==uniqslidenum(i),:);
        xy_extreme_diff=(median(xy_translation_sub(1:pos_per_slice,:))-median(xy_translation_sub(end-pos_per_slice+1:end,:)));
        if max(range(xy_translation_sub))>50
            if (xy_extreme_diff(1))>50 % only check the x since a tilted slide has larger effet on x than y when mounted on the 4-slide holder
                warning(['Slide ',num2str(i), ' is tilted COUNTER CLOCKWISE.'])
                message=append('Slide ',num2str(i), ' is tilted COUNTER CLOCKWISE.');
                app.WarningTextArea.FontColor=[1 0 0];
                app.WarningTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf(message)}];
            
            elseif xy_extreme_diff(1)<-50
                warning(['Slide ',num2str(i), ' is tilted CLOCKWISE.'])
                message=append('Slide ',num2str(i), ' is tilted CLOCKWISE.');
                app.WarningTextArea.FontColor=[1 0 0];
                app.WarningTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf(message)}];
            else
                warning(['Slide ',num2str(i), ' is grossly tilted and/or some registrations have failed. Double-check fixed positions.'])
                message=append('Slide ',num2str(i), ' is grossly tilted and/or some registrations have failed. Double-check fixed positions.');
                app.WarningTextArea.FontColor=[1 0 0];
                app.WarningTextArea.Value=[app.WarningTextArea.Value(:)', {sprintf(message)}];
            end
        end
    end
        
    %% fix position list
    data=readmatrix(posfname);
    data2=data;
    data2(:,1)=round(data2(:,1)-stage_x_dir*xy_translation_pooled(:,1)*pixelsize,3);
    data2(:,2)=round(data2(:,2)-stage_y_dir*xy_translation_pooled(:,2)*pixelsize,3);

    writematrix(data2,['reg',posfname],'Delimiter',';')


    %% check images, optional
    if checkimage>0
        alignedim={};
        for i=1:numel(imref)
            tform{i}.T(3,1:2)=xy_translation_pooled(i,:);
            alignedim{i}=imwarp(imcurr{i},tform{i},'OutputView',Rfixed);
            figure;imshowpair(double(imref{i})./1.3/max(double(imref{i}(:))), ...
                double(alignedim{i})./1.3/max(double(imref{i}(:))));
        end
    end
end