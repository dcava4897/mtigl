function [x,y,z] = correctAirfoilProfile(x,y,z)
%CORRECTAIRFOILPROFILE Corrects the rare instances in which an airfoil is
% slightly and predictably misspecified. 
% One observed instance: the first and last x-coordinates (usually = 1) are
% (somehow) misread, leading to incorrect results down the line. 

%If x is not a column vector it must be transposed:
if size(x,1) < size(x,2)
    b_trans_x = true;
else
    b_trans_x = false;
end

% Case: leading and trailing x=1 is missing
if numel(x)==(numel(z)-2) && (abs(x(1)-1)<=0.01) && (abs(x(end)-1)<=0.01) ...
        && ((abs(diff(z(1:2)))-1)<=0.01) && ((abs(diff(z(end-1:end)))-1)<=0.01)
    % This issue seems to arise when the first and last points are misread,
    % s.t. the x = 1, z = 0 rows (in the DAT file) become x = [] and z = 1. 
    % So we check if the first and last x points are *almost* 1, and the
    % first and last z points 'jump' to 1.
    x = [1;x(:);1];
    if b_trans_x
        x = x';
    end
    
    z(1) = 0;
    z(end) = 0;
    
    %Check y as well, loosely: it is usually a zeros vector, so we remake
    %it in the right size just in case
    if numel(y) ~= numel(z) && mean(abs(y)) == 0
        y = zeros(size(z));
    end
end


end

