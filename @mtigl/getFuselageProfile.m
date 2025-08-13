function [profile] = getFuselageProfile(profiles_struct, profile_uID)
    
    for i_profile = 1:numel(profiles_struct.fuselageProfiles.fuselageProfile)
        if strcmp(profiles_struct.fuselageProfiles.fuselageProfile{i_profile}.Attributes.uID, profile_uID)
            profile = profiles_struct.fuselageProfiles.fuselageProfile{i_profile};
            break;
        end
    end

end