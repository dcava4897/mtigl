function [xyz_out] = scalePoints(xyz_in, transformation)
    % Applies the scaling part of a given transformation.
    
    x_scale = str2num(transformation.scaling.x.Text);
    y_scale = str2num(transformation.scaling.y.Text);
    z_scale = str2num(transformation.scaling.z.Text);
    
    xyz_out = diag([x_scale, y_scale, z_scale]) * xyz_in;

end