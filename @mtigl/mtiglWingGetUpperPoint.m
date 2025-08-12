function [x_pt,y_pt,z_pt] = mtiglWingGetUpperPoint(mtiglHandle, wing_index, segment_index, eta, xsi)
%MTIGLWINGGETUPPERPOINT Returns point along upper surface of wing

% Note: implementation almost identical to mtiglWingGetChordPoint, consider
% creating subfunction to improve code reuse

if (eta < 0.0 || eta > 1.0) 
   error('Parameter eta not in the range 0.0 <= eta <= 1.0');
end
if (xsi < 0.0 || xsi > 1.0) 
   error('Parameter xsi not in the range 0.0 <= xsi <= 1.0');
end


if iscell(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing{wing_index};
elseif isstruct(mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index))
    wing_tmp = mtiglHandle.cpacs.vehicles.aircraft.model.wings.wing(wing_index);
else
    error('CPACS wing format is not as expected!')
end


segment_tmp = wing_tmp.segments.segment{segment_index};

% Get start and end sections
section_start   = mtigl.getWingSection(wing_tmp, segment_tmp.fromElementUID.Text);
section_end     = mtigl.getWingSection(wing_tmp, segment_tmp.toElementUID.Text);

%Get airfoil profiles
profile_start   = mtigl.getAirfoilProfile(mtiglHandle.cpacs.vehicles.profiles, section_start.elements.element.airfoilUID.Text);
profile_end     = mtigl.getAirfoilProfile(mtiglHandle.cpacs.vehicles.profiles, section_end.elements.element.airfoilUID.Text);

% Get leading edge and trailing edge points from each airfoil
[point_xyz_start, ~] = mtigl.getAirfoilUpperLower(profile_start, xsi);
[point_xyz_end,   ~] = mtigl.getAirfoilUpperLower(profile_end, xsi);


% Transform point according to profile transformation specified in section.            
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.elements.element.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.elements.element.transformation);

 % Transform point according to section transformation
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.transformation);

% Transform point according to wing transformation
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, wing_tmp.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, wing_tmp.transformation);

% Get position of starting section in wing + length of this segment
xyz_start = zeros(3,1);
for i_seg = 1:(segment_index-1)
    xyz_seg_tmp = mtigl.getWingSegmentVector(wing_tmp, wing_tmp.segments.segment{i_seg});
    xyz_start = xyz_start + xyz_seg_tmp;
end
xyz_seg = mtigl.getWingSegmentVector(wing_tmp, segment_tmp);

point_xyz_end = point_xyz_end + xyz_seg;

point_xyz = point_xyz_start + (point_xyz_end-point_xyz_start)*eta + xyz_start;

x_pt = point_xyz(1);
y_pt = point_xyz(2);
z_pt = point_xyz(3);


end


%% Local functions

% function [section] = getWingSection(wing_struct, section_uID)
%     for i_section = 1:numel(wing_struct.sections.section)
%         if strcmp(wing_struct.sections.section{i_section}.elements.element.Attributes.uID, section_uID)
%             section = wing_struct.sections.section{i_section};
%             break;
%         end
%     end
% 
% end
% 
% function [profile] = getAirfoilProfile(CPACS_struct, profile_uID)
%     for i_profile = 1:numel(CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil)
%         if strcmp(CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil{i_profile}.Attributes.uID, profile_uID)
%             profile = CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil{i_profile};
%             break;
%         end
%     end
% 
% end
% 
% function [xyz_up, xyz_lw] = getAirfoilUpperLower(airfoil, xsi)
%     % Gets upper and lwoer surface points at a given chordwise position
%  
%     
%     x_prf = [eval(['[',airfoil.pointList.x.Text,']'])];
%     y_prf = [eval(['[',airfoil.pointList.y.Text,']'])];
%     z_prf = [eval(['[',airfoil.pointList.z.Text,']'])];
%     
%     
%     %Usually airfoils are x subset of [0,1], but just to be safe:
%     %Leading edge: minimum x
%     [x_LE,~] = min(x_prf);
%     %Trailing edge: maximum x
%     [x_TE,~] = max(x_prf);
%     
%     x_xsi = interp1([0,1], [x_LE, x_TE], xsi, 'linear');
%     
%     % Assuming there is, at any point, only one upper surface and one lower
%     % surface
%     % First check the number of points which match x_xsi precisely:
%     idx_match = find(x_prf == x_xsi);
%     switch numel(idx_match)
%         case 2 %Both the upper and lower surface have exactly point which matches x_xsi, so we take them
%             [~,idx_up] = max(z_prf(idx_match));
%             [~,idx_lw] = min(z_prf(idx_match));
%             
%             xyz_up = [x_prf(idx_match(idx_up)); y_prf(idx_match(idx_up)); z_prf(idx_match(idx_up))];
%             xyz_lw = [x_prf(idx_match(idx_lw)); y_prf(idx_match(idx_lw)); z_prf(idx_match(idx_lw))];
%         case 1 % Only one is matched, so we find out which, and interpolate from the other two nearest for the other
%             [~,idx_near] = mink(abs(x_prf-x_xsi), 3);
%             idx_near = idx_near(idx_near~=idx_match);
%             
%             xyz_match = [x_prf(idx_match); y_prf(idx_match); z_prf(idx_match)];
%             xyz_intrp = interp1(x_prf(idx_near),[x_prf(idx_near), y_prf(idx_near),z_prf(idx_near)],...
%                             x_xsi, 'linear')';
%                         
%             if xyz_match(3) >= xyz_interp(3) %compare z coord
%                 xyz_up = xyz_match;
%                 xyz_lw = xyz_intrp;
%             else
%                 xyz_lw = xyz_match;
%                 xyz_up = xyz_intrp;
%             end
%         case 0 %
%             [~,idx_near] = mink(abs(x_prf-x_xsi), 4);
%             [~,idx_sort] = sort(z_prf(idx_near), 'ascend'); %Ascend -> first two are lower
%             
%             idx_lw = idx_near(idx_sort(1:2));
%             idx_up = idx_near(idx_sort(3:4));
%             
%             xyz_lw = interp1(x_prf(idx_lw),[x_prf(idx_lw), y_prf(idx_lw),z_prf(idx_lw)],...
%                             x_xsi, 'linear')';
%             xyz_up = interp1(x_prf(idx_up),[x_prf(idx_up), y_prf(idx_up),z_prf(idx_up)],...
%                             x_xsi, 'linear')';
%     end
%     
%     
% end
% 
% function [xyz_seg] = getWingSegmentVector(wing_tmp, segment_tmp)
%     [section_from] = getWingSection(wing_tmp, segment_tmp.fromElementUID.Text);
%     [section_to]   = getWingSection(wing_tmp, segment_tmp.toElementUID.Text);
%     
%     for i_pos = 1:numel(wing_tmp.positionings.positioning)
%         if isfield(wing_tmp.positionings.positioning{i_pos}, 'fromSectionUID') && ...
%            isfield(wing_tmp.positionings.positioning{i_pos}, 'toSectionUID')   && ...
%            strcmp(wing_tmp.positionings.positioning{i_pos}.fromSectionUID.Text, section_from.name.Text) && ...
%            strcmp(wing_tmp.positionings.positioning{i_pos}.toSectionUID.Text, section_to.name.Text)
%             length   = str2num(wing_tmp.positionings.positioning{i_pos}.length.Text);
%             sweep    = str2num(wing_tmp.positionings.positioning{i_pos}.sweepAngle.Text);
%             dihedral = str2num(wing_tmp.positionings.positioning{i_pos}.dihedralAngle.Text);
%             break;
%         end
%     end
%     
%     %Check signs?
%     x_vec = length*sind(sweep)*cosd(dihedral);
%     y_vec = length*cosd(sweep)*cosd(dihedral);
%     z_vec = length*sind(dihedral);
%     
%     xyz_seg = [x_vec;y_vec;z_vec];
%     
% end
% 
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

% 
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
% order = 'XYZ';%'ZYX'; % Default rotation order
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