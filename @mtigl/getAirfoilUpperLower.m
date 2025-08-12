function [xyz_up, xyz_lw] = getAirfoilUpperLower(airfoil, xsi)
    % Gets upper and lwoer surface points at a given chordwise position
 
    
    x_prf = [eval(['[',airfoil.pointList.x.Text,']'])];
    y_prf = [eval(['[',airfoil.pointList.y.Text,']'])];
    z_prf = [eval(['[',airfoil.pointList.z.Text,']'])];
    
    
    %Usually airfoils are x subset of [0,1], but just to be safe:
    %Leading edge: minimum x
    [x_LE,~] = min(x_prf);
    %Trailing edge: maximum x
    [x_TE,~] = max(x_prf);
    
    x_xsi = interp1([0,1], [x_LE, x_TE], xsi, 'linear');
    
    % Assuming there is, at any point, only one upper surface and one lower
    % surface
    % First check the number of points which match x_xsi precisely:
    idx_match = find(x_prf == x_xsi);
    switch numel(idx_match)
        case 2 %Both the upper and lower surface have exactly point which matches x_xsi, so we take them
            [~,idx_up] = max(z_prf(idx_match));
            [~,idx_lw] = min(z_prf(idx_match));
            
            xyz_up = [x_prf(idx_match(idx_up)); y_prf(idx_match(idx_up)); z_prf(idx_match(idx_up))];
            xyz_lw = [x_prf(idx_match(idx_lw)); y_prf(idx_match(idx_lw)); z_prf(idx_match(idx_lw))];
        case 1 % Only one is matched, so we find out which, and interpolate from the other two nearest for the other
            [~,idx_near] = mink(abs(x_prf-x_xsi), 3);
            idx_near = idx_near(idx_near~=idx_match);
            
            xyz_match = [x_prf(idx_match); y_prf(idx_match); z_prf(idx_match)];
            xyz_intrp = interp1(x_prf(idx_near),[x_prf(idx_near), y_prf(idx_near),z_prf(idx_near)],...
                            x_xsi, 'linear')';
                        
            if xyz_match(3) >= xyz_interp(3) %compare z coord
                xyz_up = xyz_match;
                xyz_lw = xyz_intrp;
            else
                xyz_lw = xyz_match;
                xyz_up = xyz_intrp;
            end
        case 0 %
            [~,idx_near] = mink(abs(x_prf-x_xsi), 4);
            [~,idx_sort] = sort(z_prf(idx_near), 'ascend'); %Ascend -> first two are lower
            
            idx_lw = idx_near(idx_sort(1:2));
            idx_up = idx_near(idx_sort(3:4));
            
            xyz_lw = interp1(x_prf(idx_lw),[x_prf(idx_lw), y_prf(idx_lw),z_prf(idx_lw)],...
                            x_xsi, 'linear')';
            xyz_up = interp1(x_prf(idx_up),[x_prf(idx_up), y_prf(idx_up),z_prf(idx_up)],...
                            x_xsi, 'linear')';
    end
    
    
end