function [x_pt,y_pt,z_pt] = mtiglFuselageGetPoint(mtiglHandle, fuse_index, segment_index, eta, zeta)
%MTIGLFUSELAGEGETPOINT Returns a point on the fuselage surface.

% eta: position along segment. 0 -> beginning of segment, 1 -> end of segment
% zeta: position along profile. 0 -> beginning, 1 -> end

%%

if (eta < 0.0 || eta > 1.0) 
   error('Parameter eta not in the range 0.0 <= eta <= 1.0');
end
if (zeta < 0.0 || zeta > 1.0) 
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

% Get fuselage length to this section + length of this segment
length_fus = 0;
for i_seg = 1:(segment_index-1)
    length_fus = length_fus + mtigl.getFuselageSegmentLength(fuse_tmp, fuse_tmp.segments.segment{i_seg});
    
end
length_seg = mtigl.getFuselageSegmentLength(fuse_tmp, segment_tmp);

% Get raw profiles of start and end sections
profile_start   = mtigl.getFuselageProfile(mtiglHandle.cpacs.vehicles.profiles, section_start.elements.element.profileUID.Text);
profile_end     = mtigl.getFuselageProfile(mtiglHandle.cpacs.vehicles.profiles, section_end.elements.element.profileUID.Text);

% Get desired point from raw start and end profiles
point_xyz_start = zeros(3,1);
point_xyz_end   = zeros(3,1);


[point_xyz_start(1,1), point_xyz_start(2,1), point_xyz_start(3,1)] = ...
                mtigl.getProfilePoint(profile_start, zeta);       
[point_xyz_end(1,1), point_xyz_end(2,1), point_xyz_end(3,1)] = ...
                mtigl.getProfilePoint(profile_end, zeta);

% Transform point according to profile transformation specified in section.            
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.elements.element.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.elements.element.transformation);

 % Transform point according to section transformation
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.transformation);

% Add overall fuselage dimension to points. 
% For now we assume that fuselage segment lengths are all in the x
% direction. 
% TODO: verify this! If not, apply appropriate transformations to length
% computation above.
point_xyz_start = point_xyz_start + [length_fus;            0; 0];
point_xyz_end   = point_xyz_end   + [length_fus+length_seg; 0; 0];

 
% Interpolate points:
x_pt = interp1([0;1], [point_xyz_start(1); point_xyz_end(1)], eta, 'linear');
y_pt = interp1([0;1], [point_xyz_start(2); point_xyz_end(2)], eta, 'linear');
z_pt = interp1([0;1], [point_xyz_start(3); point_xyz_end(3)], eta, 'linear');

end

%% Local functions
% function [section] = getFuselageSection(fuse_struct, section_uID)
%     for i_section = 1:numel(fuse_struct.sections.section)
%         if strcmp(fuse_struct.sections.section{i_section}.elements.element.Attributes.uID, section_uID)
%             section = fuse_struct.sections.section{i_section};
%             break;
%         end
%     end
% 
% end

% function [length] = getFuselageSegmentLength(fuse_tmp, segment_tmp)
%     [section_from] = getFuselageSection(fuse_tmp, segment_tmp.fromElementUID.Text);
%     [section_to]   = getFuselageSection(fuse_tmp, segment_tmp.toElementUID.Text);
%     
%     for i_pos = 1:numel(fuse_tmp.positionings.positioning)
%         if isfield(fuse_tmp.positionings.positioning{i_pos}, 'fromSectionUID') && ...
%            isfield(fuse_tmp.positionings.positioning{i_pos}, 'toSectionUID')   && ...
%            strcmp(fuse_tmp.positionings.positioning{i_pos}.fromSectionUID.Text, section_from.name.Text) && ...
%            strcmp(fuse_tmp.positionings.positioning{i_pos}.toSectionUID.Text, section_to.name.Text)
%             length = str2num(fuse_tmp.positionings.positioning{i_pos}.length.Text);
%             break;
%         end
%     end
%     
% end

% function [profile] = getFuselageProfile(CPACS_struct, profile_uID)
%     for i_profile = 1:numel(CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile)
%         if strcmp(CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile{i_profile}.Attributes.uID, profile_uID)
%             profile = CPACS_struct.cpacs.vehicles.profiles.fuselageProfiles.fuselageProfile{i_profile};
%             break;
%         end
%     end
% 
% end

% function [x_pt, y_pt, z_pt] = getProfilePoint(profile, zeta)
%     % Gets a point at 'zeta' location along the profile, where 0<=zeta<=1
%     
%     % The actual algorithm is somewhat different, but here we interpret
%     % zeta as the distance along the profile (as opposed, say, to the
%     % number of points specified in the profile or the angle between the
%     % first and last point). So first we find the total length of the
%     % profile (l_prf) by computing the distance from point to point, and then we
%     % linearly interpolate the point located at zeta*l_prf
%     
%     if zeta < 0 || zeta > 1
%         error(['getProfilePoint: zeta must be between 0 and 1 (zeta = ' num2str(zeta),')']);
%     end
%     
%     x_prf = [eval(['[',profile.pointList.x.Text,']'])];
%     y_prf = [eval(['[',profile.pointList.y.Text,']'])];
%     z_prf = [eval(['[',profile.pointList.z.Text,']'])];
%     
%     delta_l_prf = vecnorm(diff([x_prf,y_prf,z_prf],1),2,2);
%     l_prf = sum(delta_l_prf);
%     cum_delta_l_prf = [0; cumsum(delta_l_prf)];
%     
%     l_zeta = zeta*l_prf;
%     
%     if ismember(l_zeta, cum_delta_l_prf)
%         idx_pt = find(ismember(cum_delta_l_prf, l_zeta));
%         x_pt = x_prf(idx_pt);
%         y_pt = y_prf(idx_pt);
%         z_pt = z_prf(idx_pt);
%     else
%         x_pt = interp1(cum_delta_l_prf, x_prf, l_zeta, 'linear');
%         y_pt = interp1(cum_delta_l_prf, y_prf, l_zeta, 'linear');
%         z_pt = interp1(cum_delta_l_prf, z_prf, l_zeta, 'linear');
%         
%     end
%     
%     
% end
% function [point_xyz_t] = transformPoint(point_xyz, transformation) 
% % https://www.cpacs.de/documentation/CPACS_3_4_0_Docs/html/35b65aba-4bd5-b26f-6619-bd0da67e05db.htm
% 
% % x' = a11 x + a12 y + a13 z + a14
% % y' = a21 x + a22 y + a23 z + a24
% % z' = a31 x + a32 y + a33 z + a34
% 
% % Rotations provided in degrees
% x_rot = pi/180*str2num(transformation.rotation.x.Text);
% y_rot = pi/180*str2num(transformation.rotation.y.Text);
% z_rot = pi/180*str2num(transformation.rotation.z.Text);
% 
% x_scale = str2num(transformation.scaling.x.Text);
% y_scale = str2num(transformation.scaling.y.Text);
% z_scale = str2num(transformation.scaling.z.Text);
% 
% x_trans = str2num(transformation.translation.x.Text);
% y_trans = str2num(transformation.translation.y.Text);
% z_trans = str2num(transformation.translation.z.Text);
% 
% DCM_tmp = generateDCM(x_rot, y_rot, z_rot);
% 
% point_xyz_t = diag([x_scale, y_scale, z_scale]) * DCM_tmp * point_xyz + [x_trans;y_trans;z_trans];
% 
% 
% end


% function DCM = generateDCM(roll, pitch, yaw)
% % generateDCM - Creates a Direction Cosine Matrix (DCM) for 3D rotation
% % Generated using ChatGPT
% %
% % Syntax: DCM = generateDCM(roll, pitch, yaw, order)
% %
% % Inputs:
% %   roll  - Rotation angle (in radians) about the X-axis
% %   pitch - Rotation angle (in radians) about the Y-axis
% %   yaw   - Rotation angle (in radians) about the Z-axis
% %   order - (Optional) Rotation order as a string (e.g., 'ZYX', 'XYZ', etc.)
% %
% % Output:
% %   DCM   - 3x3 Direction Cosine Matrix for the given rotation
% 
% order = 'XYZ'; % Default rotation order
% 
% % Rotation matrices
%     Rx = [1 0 0;
%           0 cos(roll) -sin(roll);
%           0 sin(roll) cos(roll)];
% 
%     Ry = [cos(pitch) 0 sin(pitch);
%           0 1 0;
%           -sin(pitch) 0 cos(pitch)];
% 
%     Rz = [cos(yaw) -sin(yaw) 0;
%           sin(yaw) cos(yaw) 0;
%           0 0 1];
% 
%     % Build the DCM based on the specified order
%     DCM = eye(3);
%     for i = 1:length(order)
%         switch upper(order(i))
%             case 'X'
%                 DCM = DCM * Rx;
%             case 'Y'
%                 DCM = DCM * Ry;
%             case 'Z'
%                 DCM = DCM * Rz;
%             otherwise
%                 error('Invalid rotation axis "%s" in order string.', order(i));
%         end
%     end
% end
