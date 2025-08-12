function [fuse_num_sections] = mtiglFuselageGetSectionCount(mtiglHandle, fuse_index)
%MTIGLFUSELAGEGETSECTIONCOUNT Summary of this function goes here
%   Detailed explanation goes here

if iscell(mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage(fuse_index))
    fuse_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage{fuse_index};
elseif isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage(fuse_index))
    fuse_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage(fuse_index);
else
    error('CPACS fuselage format is not as expected!')
end

% TODO:Check whether CPACS specifications support this definition or if its
% just a sepcial case. 
fuse_num_sections = numel(fuse_tmp.sections.section);


end

