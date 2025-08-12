function [point_xyz_t] = transformPoint(point_xyz, transformation) 
% https://www.cpacs.de/documentation/CPACS_3_4_0_Docs/html/35b65aba-4bd5-b26f-6619-bd0da67e05db.htm

% x' = a11 x + a12 y + a13 z + a14
% y' = a21 x + a22 y + a23 z + a24
% z' = a31 x + a32 y + a33 z + a34

% Rotations provided in degrees
x_rot = pi/180*str2num(transformation.rotation.x.Text);
y_rot = pi/180*str2num(transformation.rotation.y.Text);
z_rot = pi/180*str2num(transformation.rotation.z.Text);

x_scale = str2num(transformation.scaling.x.Text);
y_scale = str2num(transformation.scaling.y.Text);
z_scale = str2num(transformation.scaling.z.Text);

x_trans = str2num(transformation.translation.x.Text);
y_trans = str2num(transformation.translation.y.Text);
z_trans = str2num(transformation.translation.z.Text);

DCM_tmp = mtigl.generateDCM(x_rot, y_rot, z_rot);

point_xyz_t = diag([x_scale, y_scale, z_scale]) * DCM_tmp * point_xyz + [x_trans;y_trans;z_trans];


end