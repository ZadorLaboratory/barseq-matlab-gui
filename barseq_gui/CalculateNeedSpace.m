function [E_space_need,D_space_need,Mounted_drive_space_need]=CalculateNeedSpace(cycle_name,row)
    Z=21;
    single_plane_size=21500000;
    if row>5
        %cycle_name=='geneseq01'
        E_space_need=single_plane_size*row*Z*5;  %Bytes per single plane*row*Z*5cycle
        D_space_need=single_plane_size*row*5;
        Mounted_drive_space_need=single_plane_size*row*5;
    elseif cycle_name=='bcseq01'
        E_space_need=single_plane_size*row*Z*5;  %Bytes per single plane*row*Z*5cycle
        D_space_need=single_plane_size*row*5;
        Mounted_drive_space_need=single_plane_size*row*5;
    elseif cycle_name == 'hyb01'
        E_space_need=single_plane_size*row*Z*6;  %Bytes per single plane*row*Z*5cycle
        D_space_need=single_plane_size*row*6;
        Mounted_drive_space_need=single_plane_size*row*6;
    else 
        E_space_need=single_plane_size*row*Z*4;  %Bytes per single plane*row*Z*5cycle
        D_space_need=single_plane_size*row*4;
        Mounted_drive_space_need=single_plane_size*row*4;
    end
end