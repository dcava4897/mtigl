function [xyz_LE, xyz_TE] = getAirfoilLETE(airfoil)
    % Gets points at airfoil's leading and trailing edge
 
    
    x_prf = [eval(['[',airfoil.pointList.x.Text,']'])];
    y_prf = [eval(['[',airfoil.pointList.y.Text,']'])];
    z_prf = [eval(['[',airfoil.pointList.z.Text,']'])];
    
    
    %Leading edge: minimum x
    [~,idx_LE] = min(x_prf);
    %Trailing edge: maximum x
    [~,idx_TE] = max(x_prf);
    
    xyz_LE = [x_prf(idx_LE); y_prf(idx_LE); z_prf(idx_LE)];
    xyz_TE = [x_prf(idx_TE); y_prf(idx_TE); z_prf(idx_TE)];
    
end