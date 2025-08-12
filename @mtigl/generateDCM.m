function DCM = generateDCM(roll, pitch, yaw)
% generateDCM - Creates a Direction Cosine Matrix (DCM) for 3D rotation
% Generated using ChatGPT
%
% Syntax: DCM = generateDCM(roll, pitch, yaw, order)
%
% Inputs:
%   roll  - Rotation angle (in radians) about the X-axis
%   pitch - Rotation angle (in radians) about the Y-axis
%   yaw   - Rotation angle (in radians) about the Z-axis
%   order - (Optional) Rotation order as a string (e.g., 'ZYX', 'XYZ', etc.)
%
% Output:
%   DCM   - 3x3 Direction Cosine Matrix for the given rotation

    order = 'XYZ'; % Default rotation order

% Rotation matrices
    Rx = [1 0 0;
          0 cos(roll) -sin(roll);
          0 sin(roll) cos(roll)];

    Ry = [cos(pitch) 0 sin(pitch);
          0 1 0;
          -sin(pitch) 0 cos(pitch)];

    Rz = [cos(yaw) -sin(yaw) 0;
          sin(yaw) cos(yaw) 0;
          0 0 1];

    % Build the DCM based on the specified order
    DCM = eye(3);
    for i = 1:length(order)
        switch upper(order(i))
            case 'X'
                DCM = DCM * Rx;
            case 'Y'
                DCM = DCM * Ry;
            case 'Z'
                DCM = DCM * Rz;
            otherwise
                error('Invalid rotation axis "%s" in order string.', order(i));
        end
    end
end