function [wing_UID] = mtiglWingGetUID(mtiglHandle, wing_index)
%MTIGLWINGGETUID Summary of this function goes here
%   Detailed explanation goes here

if iscell(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{wing_index};
elseif isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index);
else
    error('CPACS wing format is not as expected!')
end

wing_UID = wing_tmp.Attributes.uID;

end

