function [circumference] = mtiglFuselageGetCircumference(mtiglHandle,fuse_index,segment_index,eta)
%MTIGLFUSELAGEGETCIRCUMFERENCE Returns the circumference of the curren

% eta: position along segment. 0 -> beginning of segment, 1 -> end of segment

if (eta < 0.0 || eta > 1.0) 
   error('Parameter eta not in the range 0.0 <= eta <= 1.0');
end

fuse_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.fuselages.fuselage(fuse_index);
if iscell(fuse_tmp)
    fuse_tmp = fuse_tmp{:};
end

% TODO:  check whether it is always a cell. 
segment_tmp = fuse_tmp.segments.segment{segment_index};

% Get start and end sections
section_start   = mtigl.getFuselageSection(fuse_tmp, segment_tmp.fromElementUID.Text);
section_end     = mtigl.getFuselageSection(fuse_tmp, segment_tmp.toElementUID.Text);

% Get raw profiles of start and end sections
profile_start   = mtigl.getFuselageProfile(mtiglHandle.cpacs.vehicles.profiles,...
                    section_start.elements.element.profileUID.Text);
profile_end     = mtigl.getFuselageProfile(mtiglHandle.cpacs.vehicles.profiles,...
                    section_end.elements.element.profileUID.Text);

xyz_prf_start = mtigl.getAllProfilePoints(profile_start);
xyz_prf_end   = mtigl.getAllProfilePoints(profile_end);

xyz_prf_start = mtigl.scalePoints( xyz_prf_start, section_start.elements.element.transformation);
xyz_prf_end   = mtigl.scalePoints( xyz_prf_end,   section_end.elements.element.transformation);

xyz_prf_start = mtigl.scalePoints( xyz_prf_start, section_start.transformation);
xyz_prf_end   = mtigl.scalePoints( xyz_prf_end,   section_end.transformation);

% Here we simply sum the distances between all points in each profile
% (including from last to first) and interpolate the circumference to eta
circumference_start = sum(vecnorm(diff([xyz_prf_start,xyz_prf_start(:,1)]', 1) ,2,2));
circumference_end   = sum(vecnorm(diff([xyz_prf_end,xyz_prf_end(:,1)]' , 1)    ,2,2));

circumference = interp1([0,1],[circumference_start, circumference_end], eta, 'linear');

% 'Empirical' correction to the results. TIGL probably uses a more 
% sophisticated method to compute the circumference, mybe fitting a curve 
% to the points? In the meantime this gets the difference below 0.01%
% TODO: implement correct algorithm to eliminate this correction factor
circumference = circumference*1.001; 
end

%% Local functions

% function [xyz_pts] = getAllProfilePoints(profile)
%     xyz_pts = [eval(['[',profile.pointList.x.Text,']']), ...
%                eval(['[',profile.pointList.y.Text,']']), ...
%                eval(['[',profile.pointList.z.Text,']'])]';
% end
% 
% function [xyz_out] = scalePoints(xyz_in, transformation)
%     % Applies the scaling part of a given transformation.
%     
%     x_scale = str2num(transformation.scaling.x.Text);
%     y_scale = str2num(transformation.scaling.y.Text);
%     z_scale = str2num(transformation.scaling.z.Text);
%     
%     xyz_out = diag([x_scale, y_scale, z_scale]) * xyz_in;
% 
% end
% 
% function [section] = getFuselageSection(fuse_struct, section_uID)
%     for i_section = 1:numel(fuse_struct.sections.section)
%         if strcmp(fuse_struct.sections.section{i_section}.elements.element.Attributes.uID, section_uID)
%             section = fuse_struct.sections.section{i_section};
%             break;
%         end
%     end
% 
% end
% 
% function [profile] = getFuselageProfile(CPACS_struct, profile_uID)
%     for i_profile = 1:numel(CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile)
%         if strcmp(CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile{i_profile}.Attributes.uID, profile_uID)
%             profile = CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile{i_profile};
%             break;
%         end
%     end
% 
% end
