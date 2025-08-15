function [x_pt,y_pt,z_pt] = mtiglWingGetChordPoint(mtiglHandle, wing_index, segment_index, eta, xsi )
%MTIGLWINGGETCHORDPOINT Returns a point along the chord line. 
% eta is the spanwise position (within the selected segment) and xsi the
% chordwise position.
% 
% NB: In comparisons with tigl API calls this function is accurate to
% within +-0.01 in x and z directions, and perfect in y-axis


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
profile_start   = mtigl.getAirfoilProfile(mtiglHandle.cpacs.vehicles.profiles,...
                    section_start.elements.element.airfoilUID.Text);
profile_end     = mtigl.getAirfoilProfile(mtiglHandle.cpacs.vehicles.profiles,...
                    section_end.elements.element.airfoilUID.Text);

% Get leading edge and trailing edge points from each airfoil
[xyz_LE_start, xyz_TE_start] = mtigl.getAirfoilLETE(profile_start);
[xyz_LE_end,   xyz_TE_end]   = mtigl.getAirfoilLETE(profile_end);

% Interpolate b/w LE and TE to get the points at xsi
point_xyz_start = interp1([0,1], [xyz_LE_start, xyz_TE_start]', xsi, 'linear')';
point_xyz_end   = interp1([0,1], [xyz_LE_end, xyz_TE_end]',     xsi, 'linear')';

% Transform point according to profile transformation specified in section.            
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.elements.element.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.elements.element.transformation);

 % Transform point according to section transformation
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, section_start.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, section_end.transformation);

% % Transform point according to wing transformation
% [point_xyz_start] = mtigl.transformPoint(point_xyz_start, wing_tmp.transformation);
% [point_xyz_end]   = mtigl.transformPoint(point_xyz_end, wing_tmp.transformation);

% Get position of starting section in wing + vector from start to end
% of this segment
xyz_start = zeros(3,1);
for i_seg = 1:(segment_index-1)
    xyz_seg_tmp = mtigl.getWingSegmentVector(wing_tmp, wing_tmp.segments.segment{i_seg});
    xyz_start = xyz_start + xyz_seg_tmp;
end
xyz_seg = mtigl.getWingSegmentVector(wing_tmp, segment_tmp);

point_xyz_start = point_xyz_start + xyz_start;
point_xyz_end   = point_xyz_end   + xyz_start + xyz_seg;

% Transform point according to wing transformation
[point_xyz_start] = mtigl.transformPoint(point_xyz_start, wing_tmp.transformation);
[point_xyz_end]   = mtigl.transformPoint(point_xyz_end, wing_tmp.transformation);

point_xyz = point_xyz_start + (point_xyz_end-point_xyz_start)*eta;

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

% function [profile] = getAirfoilProfile(CPACS_struct, profile_uID)
%     for i_profile = 1:numel(CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil)
%         if strcmp(CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil{i_profile}.Attributes.uID, profile_uID)
%             profile = CPACS_struct.cpacs.vehicles.profiles.wingAirfoils.wingAirfoil{i_profile};
%             break;
%         end
%     end
% 
% end

% function [xyz_LE, xyz_TE] = getAirfoilLETE(airfoil)
%     % Gets points at airfoil's leading and trailing edge
%  
%     
%     x_prf = [eval(['[',airfoil.pointList.x.Text,']'])];
%     y_prf = [eval(['[',airfoil.pointList.y.Text,']'])];
%     z_prf = [eval(['[',airfoil.pointList.z.Text,']'])];
%     
%     
%     %Leading edge: minimum x
%     [~,idx_LE] = min(x_prf);
%     %Trailing edge: maximum x
%     [~,idx_TE] = max(x_prf);
%     
%     xyz_LE = [x_prf(idx_LE); y_prf(idx_LE); z_prf(idx_LE)];
%     xyz_TE = [x_prf(idx_TE); y_prf(idx_TE); z_prf(idx_TE)];
%     
% end

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