function [section] = getWingSection(wing_struct, section_uID)
    for i_section = 1:numel(wing_struct.sections.section)
        if strcmp(wing_struct.sections.section{i_section}.elements.element.Attributes.uID, section_uID)
            section = wing_struct.sections.section{i_section};
            break;
        end
    end

end