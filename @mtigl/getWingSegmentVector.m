function [xyz_seg] = getWingSegmentVector(wing_tmp, segment_tmp)
    [section_from] = mtigl.getWingSection(wing_tmp, segment_tmp.fromElementUID.Text);
    [section_to]   = mtigl.getWingSection(wing_tmp, segment_tmp.toElementUID.Text);
    
    for i_pos = 1:numel(wing_tmp.positionings.positioning)
        if isfield(wing_tmp.positionings.positioning{i_pos}, 'fromSectionUID') && ...
           isfield(wing_tmp.positionings.positioning{i_pos}, 'toSectionUID')   && ...
           strcmp(wing_tmp.positionings.positioning{i_pos}.fromSectionUID.Text, section_from.name.Text) && ...
           strcmp(wing_tmp.positionings.positioning{i_pos}.toSectionUID.Text, section_to.name.Text)
            length   = str2num(wing_tmp.positionings.positioning{i_pos}.length.Text);
            sweep    = str2num(wing_tmp.positionings.positioning{i_pos}.sweepAngle.Text);
            dihedral = str2num(wing_tmp.positionings.positioning{i_pos}.dihedralAngle.Text);
            break;
        end
    end
    
    %Check signs?
    x_vec = length*sind(sweep)*cosd(dihedral);
    y_vec = length*cosd(sweep)*cosd(dihedral);
    z_vec = length*sind(dihedral);
    
    xyz_seg = [x_vec;y_vec;z_vec];
    
end