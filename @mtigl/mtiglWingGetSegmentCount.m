function [wing_num_seg] = mtiglWingGetSegmentCount(mtiglHandle, wing_index)
%MTIGLWINGGETSEGMENTCOUNT Summary of this function goes here
%   Detailed explanation goes here


if iscell(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{wing_index};
elseif isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index);
else
    error('CPACS wing format is not as expected!')
end

% TODO:Check whether CPACS specifications support this definition or if its
% just a special case. 
wing_num_seg = numel(wing_tmp.segments.segment);
end

