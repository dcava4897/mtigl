function [symmetry_enum] = mtiglWingGetSymmetry(mtiglHandle,wing_index)
%MTIGLWINGGETSYMMETRY Summary of this function goes here
%   Detailed explanation goes here

if iscell(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{wing_index};
elseif isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index);
else
    error('CPACS wing format is not as expected!')
end

switch wing_tmp.Attributes.symmetry
    case 'x-y-plane'
        symmetry_enum = 1;
    case 'x-z-plane'
        symmetry_enum = 2;
    case 'y-z-plane'
        symmetry_enum = 3;
    otherwise
        symmetry_enum = 0;
end

end

