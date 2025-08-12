function [b_wing] = mtiglWingGetSpan(mtiglHandle, wingUID)
% Returns the span of a wing. Thiss implementation is vastly simplified
% compared to the tigl implementation: we automatically assume that the
% y-direction is what we're interested in. 

%% Find wing from wingUID
b_winguid_found = false;

if isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing)
    if strcmp(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing.Attributes.uID, wingUID)
        wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing;
        b_winguid_found = true;
        wing_index = 1;
    end
else
    for i_wing = 1:numel(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing)
        if strcmp(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{i_wing}.Attributes.uID, wingUID)
           wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{i_wing};
           b_winguid_found = true;
           wing_index = i_wing;
           break;
        end
    end
end

if ~b_winguid_found
    error(['mtiglWingGetSpan: wingUID ', wingUID, ' not found.']);
end

%% Assemble lengths, sweep, and dihedral angles of all segments

lengths_tmp  =  zeros(numel(wing_tmp.positionings.positioning),1);
sweep_tmp    =  zeros(numel(wing_tmp.positionings.positioning),1);
dihedral_tmp =  zeros(numel(wing_tmp.positionings.positioning),1);

for i_pos = 1:numel(wing_tmp.positionings.positioning)
    lengths_tmp(i_pos)  = str2num(wing_tmp.positionings.positioning{i_pos}.length.Text);
    sweep_tmp(i_pos)    = str2num(wing_tmp.positionings.positioning{i_pos}.sweepAngle.Text);
    dihedral_tmp(i_pos) = str2num(wing_tmp.positionings.positioning{i_pos}.dihedralAngle.Text);
    
end

y_seg = cosd(sweep_tmp) .* cosd(dihedral_tmp) .* lengths_tmp;

wing_symmetry = mtiglWingGetSymmetry(mtiglHandle,wing_index);

if wing_symmetry == 2
    b_wing = 2 * sum(y_seg);
else
    b_wing = sum(y_seg);
end


end

