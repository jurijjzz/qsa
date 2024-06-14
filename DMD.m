classdef DMD < alpV42
% Device class for ViALUX V-7000 DMDs using the ALP-4 API.
% 
% Some parts were inspired by "WS6 or WS7 wavemeter driver" on the Matlab
% file exchange, created by Jakko de Jong.
%    
% Matthijs Velsink, 2019-2020
    
    properties (SetAccess = private)
        DeviceId;
    end
    
    properties (Constant)
        DeviceNum = int32(8122); 
    end
    
    % Regulate that only one instance of DMD can exist with a 
    % class-wide, static method
    methods (Static)
        
        function dmd = getInstance()
            % The "effective" constructor, called as DMD.getInstance
            warning on;
            persistent DMDRef
            if isempty(DMDRef) || ~isvalid(DMDRef)
                DMDRef = DMD();
            end
            dmd = DMDRef;
        end
        
    end
    
    % Private methods for internal use
    methods (Access = private)

        function obj = DMD()
            % Constructor (can only be called by the static getInstance
            % function)
            obj@alpV42; % Makes sure ALP-4 library is loaded first.            
            % Load devices
            for i = 1:length(obj.DeviceNum)
                obj.DeviceId(i) = obj.AlpDevAlloc(obj.DeviceNum(i), obj.C.ALP_DEFAULT);
            end
            fprintf('Loaded devices.\n')
        end      

    end    
    
    % Exposed methods for external use of the ViALUX DMD
    methods (Access = public)
        
        function delete(obj)
            % Halt and free devices
            for i = 1:length(obj.DeviceId)
                obj.AlpDevHalt(obj.DeviceId(i));
                obj.AlpDevFree(obj.DeviceId(i));
            end 
            fprintf('Halted and freed ALP devices.\n')
        end               
        
    end  
    
end