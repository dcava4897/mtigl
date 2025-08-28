function [x_pt, y_pt, z_pt] = getProfilePoint(profile, zeta)
    % Gets a point at 'zeta' location along the profile, where 0<=zeta<=1
    
    % The actual algorithm is somewhat different, but here we interpret
    % zeta as the distance along the profile (as opposed, say, to the
    % number of points specified in the profile or the angle between the
    % first and last point). So first we find the total length of the
    % profile (l_prf) by computing the distance from point to point, and then we
    % linearly interpolate the point located at zeta*l_prf
    
    if zeta < 0 || zeta > 1
        error(['getProfilePoint: zeta must be between 0 and 1 (zeta = ' num2str(zeta),')']);
    end
    
    x_prf = [eval(['[',profile.pointList.x.Text,']'])];
    y_prf = [eval(['[',profile.pointList.y.Text,']'])];
    z_prf = [eval(['[',profile.pointList.z.Text,']'])];
    
    [x_prf,y_prf,z_prf] = mtigl.correctAirfoilProfile(x_prf,y_prf,z_prf);
    
    delta_l_prf = vecnorm(diff([x_prf,y_prf,z_prf],1),2,2);
    l_prf = sum(delta_l_prf);
    cum_delta_l_prf = [0; cumsum(delta_l_prf)];
    
    l_zeta = zeta*l_prf;
    
    if ismember(l_zeta, cum_delta_l_prf)
        idx_pt = find(ismember(cum_delta_l_prf, l_zeta));
        x_pt = x_prf(idx_pt);
        y_pt = y_prf(idx_pt);
        z_pt = z_prf(idx_pt);
    else
        x_pt = interp1(cum_delta_l_prf, x_prf, l_zeta, 'linear');
        y_pt = interp1(cum_delta_l_prf, y_prf, l_zeta, 'linear');
        z_pt = interp1(cum_delta_l_prf, z_prf, l_zeta, 'linear');
        
    end
    
    
end