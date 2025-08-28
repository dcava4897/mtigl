classdef mtigl < handle
    %MTIGL This class serves as: 
    %  1) a handle for a CPACS struct (obtained by loading a CPACS XML file
    %     using xml2struct
    %  2) a container for functions which mimic/replace certain TiGL API calls
    
    properties
        cpacs struct
    end
    
    methods
        function obj = mtigl(cpacs_struct_in)
            %MTIGL Construct an instance of this class

            obj.cpacs = cpacs_struct_in;
        end

    end
    
    % TiGL API calls:
    methods (Access = public)
        % Fuselage
        [circumference]     = mtiglFuselageGetCircumference(obj,fuse_index,segment_index,eta)
        [fuse_index]        = mtiglFuselageGetIndex(obj, fuse_uID)
        [x_pt,y_pt,z_pt]    = mtiglFuselageGetPoint(obj, fuse_index, segment_index, eta, zeta)
        [fuse_num_sections] = mtiglFuselageGetSectionCount(obj, fuse_index)
        
        % Wing
        [wing_UID]       = mtiglWingGetUID(obj, wing_index)
        [wing_num_seg]   = mtiglWingGetSegmentCount(obj, wing_index)
        [symmetry_enum]  = mtiglWingGetSymmetry(obj,wing_index)
        [b_wing]         = mtiglWingGetSpan(obj, wingUID)
        [x_pt,y_pt,z_pt] = mtiglWingGetChordPoint(obj, wing_index, segment_index, eta, xsi )
        [x_pt,y_pt,z_pt] = mtiglWingGetLowerPoint(obj, wing_index, segment_index, eta, xsi)
        [x_pt,y_pt,z_pt] = mtiglWingGetUpperPoint(obj, wing_index, segment_index, eta, xsi)
    end
    
    % Internal methods
    methods (Access = protected,Static) 
        [profile] = getFuselageProfile(profiles_struct, profile_uID)
        [xyz_pts] = getAllProfilePoints(profile_struct)
        [section] = getFuselageSection(fuse_struct, section_uID)
        [length]  = getFuselageSegmentLength(fuse_tmp, segment_tmp)
        [x_pt, y_pt, z_pt] = getProfilePoint(profile, zeta)
        
        [profile] = getAirfoilProfile(profiles_struct, profile_uID)
        [section] = getWingSection(wing_struct, section_uID)
        [xyz_seg] = getWingSegmentVector(wing_tmp, segment_tmp)
        [xyz_up, xyz_lw] = getAirfoilUpperLower(airfoil, xsi)
        [xyz_LE, xyz_TE] = getAirfoilLETE(airfoil)
        
        [point_xyz_t] = transformPoint(point_xyz, transformation) 
        [xyz_out]     = scalePoints(xyz_in, transformation)
        [DCM]         = generateDCM(roll, pitch, yaw)
        
        [x,y,z]   = correctAirfoilProfile(x,y,z)
        
    end
    
    
    
end

