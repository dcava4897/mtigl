function [length] = getFuselageSegmentLength(fuse_tmp, segment_tmp)
    [section_from] = mtigl.getFuselageSection(fuse_tmp, segment_tmp.fromElementUID.Text);
    [section_to]   = mtigl.getFuselageSection(fuse_tmp, segment_tmp.toElementUID.Text);
    
    for i_pos = 1:numel(fuse_tmp.positionings.positioning)
        if isfield(fuse_tmp.positionings.positioning{i_pos}, 'fromSectionUID') && ...
           isfield(fuse_tmp.positionings.positioning{i_pos}, 'toSectionUID')   && ...
           strcmp(fuse_tmp.positionings.positioning{i_pos}.fromSectionUID.Text, section_from.name.Text) && ...
           strcmp(fuse_tmp.positionings.positioning{i_pos}.toSectionUID.Text, section_to.name.Text)
            length = str2num(fuse_tmp.positionings.positioning{i_pos}.length.Text);
            break;
        end
    end
    
end