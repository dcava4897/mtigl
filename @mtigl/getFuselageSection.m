function [section] = getFuselageSection(fuse_struct, section_uID)
    for i_section = 1:numel(fuse_struct.sections.section)
        if strcmp(fuse_struct.sections.section{i_section}.elements.element.Attributes.uID, section_uID)
            section = fuse_struct.sections.section{i_section};
            break;
        end
    end

end