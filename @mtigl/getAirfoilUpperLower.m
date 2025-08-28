function [xyz_up, xyz_lw] = getAirfoilUpperLower(airfoil, xsi)
    % Gets upper and lwoer surface points at a given chordwise position
 
    
    x_prf = [eval(['[',airfoil.pointList.x.Text,']'])];
    y_prf = [eval(['[',airfoil.pointList.y.Text,']'])];
    z_prf = [eval(['[',airfoil.pointList.z.Text,']'])];
    
     [x_prf,y_prf,z_prf] = mtigl.correctAirfoilProfile(x_prf,y_prf,z_prf);
     
    %Usually airfoils are x subset of [0,1], but just to be safe:
    %Leading edge: minimum x
    [x_LE,idx_LE] = min(x_prf);
    %Trailing edge: maximum x
    [x_TE,idx_TE] = max(x_prf);
    
    x_xsi = interp1([0,1], [x_LE, x_TE], xsi, 'linear');
    
    
    % Assume the profile starts at LE or TE, and traces a
    % continuous line to the other end and back, going either up first or
    % down. 
    % We first split the points into the upper and lower surface, then find
    % the points individually
%     
    switch interp1([x_LE, x_TE], [0 1], x_prf(1), 'nearest')
        case 0 %Starts (and ends) at leading edge
            idx_A = [1:idx_TE];
            idx_B = [idx_TE:numel(x_prf)];
        case 1 %Starts (and ends) at trailing edge
            idx_A = [1:idx_LE];
            idx_B = [idx_LE:numel(x_prf)];
    end
    
    % Figure out which side is upper and lower:
    if mean(z_prf(idx_A))>= mean(z_prf(idx_B)) % -> A is upper
        idx_up_srf = idx_A;
        idx_lw_srf = idx_B;
    else %B is upper
        idx_up_srf = idx_B;
        idx_lw_srf = idx_A;
    end
    
    xyz_lw = interp1(x_prf(idx_lw_srf),[x_prf(idx_lw_srf), y_prf(idx_lw_srf),z_prf(idx_lw_srf)],...
                            x_xsi, 'linear')';
    xyz_up = interp1(x_prf(idx_up_srf),[x_prf(idx_up_srf), y_prf(idx_up_srf),z_prf(idx_up_srf)],...
                            x_xsi, 'linear')';
      
%     %%
%     % Assuming there is, at any point, only one upper surface and one lower
%     % surface
%     % First check the number of points which match x_xsi precisely:
%     idx_match = find(x_prf == x_xsi);
%     
%     if ismember(idx_match, [idx_LE, idx_TE]) % in this case we picked either the leading or trailing edge, so both points are right at the edge.
%         idx_match = [idx_match;idx_match];
%     end
%         
%         
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
%             if xyz_match(3) >= xyz_intrp(3) %compare z coord
%                 xyz_up = xyz_match;
%                 xyz_lw = xyz_intrp;
%             else
%                 xyz_lw = xyz_match;
%                 xyz_up = xyz_intrp;
%             end
%         case 0 %
%             [~,idx_near] = mink(abs(x_prf-x_xsi), 4);
%             
%             % Special case:
%             % If one of these is at the leading/trailing edge and there is
%             % only one point at the edge (often the case for leading edge),
%             % we need to double the one point and remove the furthest point
%             if numel( find(x_prf(idx_near)<x_xsi)) == 1  %LE
%                 idx_near_le = idx_near((x_prf(idx_near)<x_xsi));
%                 % Presumably the upper and lower points are  ~evenly
%                 % spaced, so the 3 nearest will include 1 upper, 1 lower,
%                 % and the one at the leading edge.
%                 [~,idx_near] = mink(abs(x_prf-x_xsi), 3);
%                 idx_near = [idx_near;idx_near_le];
%             elseif numel( find(x_prf(idx_near)>x_xsi)) == 1 %TE
%                 % Idem above
%                 idx_near_te = idx_near((x_prf(idx_near)>x_xsi));
%                 
%                 [~,idx_near] = mink(abs(x_prf-x_xsi), 3);
%                 idx_near = [idx_near;idx_near_te];
%             end
%             
%             % Sort to separate upper and lwoer
%             [~,idx_sort] = sort(z_prf(idx_near), 'ascend'); %Ascend -> first two are lower
%             
%             idx_lw = idx_near(idx_sort(1:2));
%             idx_up = idx_near(idx_sort(3:4));
%             
%             % Resort to get ascending order for interpolation
%             [~,idx_sort_lw] = sort(x_prf(idx_lw), 'ascend'); 
%             idx_lw = idx_lw(idx_sort_lw);
%             [~,idx_sort_up] = sort(x_prf(idx_up), 'ascend'); 
%             idx_up = idx_up(idx_sort_up);
%             
%             try
%             xyz_lw = interp1(x_prf(idx_lw),[x_prf(idx_lw), y_prf(idx_lw),z_prf(idx_lw)],...
%                             x_xsi, 'linear')';
%             xyz_up = interp1(x_prf(idx_up),[x_prf(idx_up), y_prf(idx_up),z_prf(idx_up)],...
%                             x_xsi, 'linear')';
%             catch
%                 [x_prf(idx_lw), y_prf(idx_lw),z_prf(idx_lw)]
%                 [x_prf(idx_up), y_prf(idx_up),z_prf(idx_up)]
%                 x_xsi
%             end
%     end
    
    
end