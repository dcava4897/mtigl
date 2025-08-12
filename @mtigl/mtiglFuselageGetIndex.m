function [fuse_index] = mtiglFuselageGetIndex(mtiglHandle, fuse_uID)
%MTIGLFUSELAGE Summary of this function goes here
%   Detailed explanation goes here

fuselage_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage;

% TODO: No known example of more than one fuselage, but wings work like this. 
%       Maybe check CPACS spec eventually, in the meantime we treat it the
%       same.
if numel(fuselage_tmp) == 1
    fuse_index = 1;
else
    for fuse_index = 1:numel(fuselage_tmp)
        %Assume they are cells
        if strcmp(fuselage_tmp{fuse_index}.Attributes.uID, fuse_uID)
            break;
        end
    end
end

end

