function [profile] = getAirfoilProfile(profiles_struct, profile_uID)
    for i_profile = 1:numel(profiles_struct.wingAirfoils.wingAirfoil)
        if strcmp(profiles_struct.wingAirfoils.wingAirfoil{i_profile}.Attributes.uID, profile_uID)
            profile = profiles_struct.wingAirfoils.wingAirfoil{i_profile};
            break;
        end
    end

end