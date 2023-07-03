function [aquisition_space_need,maxproj_space_need, archive_space_need]=CalculateNeedSpace(cycle_name,row)
    Z=21;
    single_plane_size=21500000;
    if row>5
        %cycle_name=='geneseq01'
        aquisition_space_need=single_plane_size*row*Z*5;  %Bytes per single plane*row*Z*5cycle
        maxproj_space_need=single_plane_size*row*5;
        archive_space_need=single_plane_size*row*5;
    elseif cycle_name=='bcseq01'
        aquisition_space_need=single_plane_size*row*Z*5;  %Bytes per single plane*row*Z*5cycle
        maxproj_space_need=single_plane_size*row*5;
        archive_space_need=single_plane_size*row*5;
    elseif cycle_name == 'hyb01'
        aquisition_space_need=single_plane_size*row*Z*6;  %Bytes per single plane*row*Z*5cycle
        maxproj_space_need=single_plane_size*row*6;
        archive_space_need=single_plane_size*row*6;
    else 
        aquisition_space_need=single_plane_size*row*Z*4;  %Bytes per single plane*row*Z*5cycle
        maxproj_space_need=single_plane_size*row*4;
        archive_space_need=single_plane_size*row*4;
    end
end