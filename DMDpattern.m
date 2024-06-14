classdef DMDpattern < handle
% Class for pattern generation based on a binary LUT, with phase and
% amplitude modulation with a 4x4 superpixel method.
% 
% Details on the method can be found in 'Superpixel-based spatial amplitude 
% and phase modulation using a digital micromirror device' by S.A. Goorden,
% J. Bertolotti and A.P. Mosk (Opt. Express 22, 17999-18009).
%    
% Matthijs Velsink, 2019-2020

properties (SetAccess = private)
    resDMD;         % DMD resolution
    resSuper;       % Super pixel resolution
    pattern;        % Pattern buffer for direct bit-writing to DMD
    maxAmp;         % Maximum electric field amplitude for normalization
    resAmp;         % Discretized amplitude resolution
    resPhase;       % Discretized phase resolution
    bytePhase;      % Byte table for phase-only modulation
    byteAmpPhase;   % Byte table for amplitude and phase modulation
    twoPixelPhaseRow2ind;       % For finding table indices
    twoPixelAmpPhaseRow2ind;    % For finding table indices
end

methods
    
    function obj = DMDpattern(resX, resY)
        % Instantiate the pattern generator with resolution, horizontal is
        % resX and vertical is resY. Due to LUT reasons, the horizontal 
        % must be divisible by 16 and the vertical by 4.
        if mod(resX, 16) || mod(resY, 4)
            error('Horizontal resolution must be multiple of 16, ...vertical must be multiple of 4.')
        end
        obj.resDMD = [resX, resY];
        obj.resSuper = obj.resDMD/4;    % Must be 4, LUT is hard-coded
        % Pre-allocate binary pattern (row-aligned)
        obj.pattern = zeros(resX/8, resY, 'uint8');        
        % Load relevant constants from LUT
        LUT = load('LUT.mat');
        obj.maxAmp = LUT.maxAmp;
        obj.resAmp = double(LUT.resAmp);
        obj.resPhase = double(LUT.resPhase);
        % Load relevant tables from LUT
        obj.bytePhase = LUT.bytePhase;
        obj.byteAmpPhase = LUT.byteAmpPhase;
        % Load indexers for full amp, phase and row indexing
        rowMatrix = zeros(resX/8, resY/4, 4, 'uint32');
        for i = 0:3
            rowMatrix(1:2:end, :, i + 1) = i;
            rowMatrix(2:2:end, :, i + 1) = mod(i + 2, 4);
        end
        obj.twoPixelPhaseRow2ind = @(p1, p2, row) LUT.twoPixelPhaseRow2ind(p1, p2, rowMatrix(:, :, row + 1));
        obj.twoPixelAmpPhaseRow2ind = @(a1, a2, p1, p2, row) LUT.twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, rowMatrix(:, :, row + 1));      
        % This complex indexing is necessary because for every two pixels
        % the row shifts by 2. The LUT takes care of the second pixel in
        % every two pixels for 8 bit to 1 byte conversion for two pixels.
        % The rowMatrix indexing takes care of the row shift for every
        % second pixel pair.
    end
    
    function pattern = getPatternFromField(obj, amplitude, phase)
        % Returns pattern buffer for direct bit-writing to DMD, based on
        % amplitude and phase data for each superpixel. The sizes of these 
        % matrices should be equal to resSuper. 0 <= amplitude <= maxAmp 
        % and 0 <= phase <= 2*pi.
        if ~all(size(amplitude) == obj.resSuper) || ~all(size(phase) == obj.resSuper)
            error('Size of field matrices must be equal to resDMD/n.');
        end
        if any((amplitude(:) > obj.maxAmp) | (amplitude(:) < 0))
            error('Amplitude must be between 0 and maxAmp.');
        end
        if any((phase(:) > 2*pi) | (phase(:) < 0))
            error('Phase must be between 0 and 2*pi.');
        end
        % Discretize amplitude and phase
        a = uint32((obj.resAmp - 1)*(amplitude/obj.maxAmp));
        p = uint32((obj.resPhase - 1)*phase/(2*pi));
        % Find pattern and return
        a1 = a(1:2:end, :); % First pixel per byte
        a2 = a(2:2:end, :); % Second pixel per byte
        p1 = p(1:2:end, :); % First pixel per byte
        p2 = p(2:2:end, :); % Second pixel per byte
        for row = 0:3
            ind = obj.twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, row);
            obj.pattern(:, (1:4:end) + row) = obj.byteAmpPhase(ind);   
        end
        pattern = obj.pattern;
    end
    
    function pattern = getPatternFromFieldInd(obj, amplitude, phase)
        % Returns pattern buffer for direct bit-writing to DMD, based on
        % discretized integer amplitude and phase data for each superpixel.
        % The sizes of these matrices should be equal to resSuper. 
        % 0 <= amplitude <= resAmp - 1 and 0 <= phase <= resPhase - 1.
        if ~all(size(amplitude) == obj.resSuper) || ~all(size(phase) == obj.resSuper)
            error('Size of field matrices must be equal to resDMD/n.');
        end
        if any((amplitude(:) > obj.resAmp - 1) | (amplitude(:) < 0))
            error('Amplitude must be between 0 and %d.', obj.resAmp - 1);
        end
        if any((phase(:) > obj.resPhase - 1) | (phase(:) < 0))
            error('Phase must be between 0 and %d.', obj.resPhase - 1);
        end
        a = uint32(amplitude);
        p = uint32(phase);
        % Find pattern and return
        a1 = a(1:2:end, :); % First pixel per byte
        a2 = a(2:2:end, :); % Second pixel per byte
        p1 = p(1:2:end, :); % First pixel per byte
        p2 = p(2:2:end, :); % Second pixel per byte
        for row = 0:3
            ind = obj.twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, row);
            obj.pattern(:, (1:4:end) + row) = obj.byteAmpPhase(ind);   
        end
        pattern = obj.pattern;
    end
    
    function pattern = getPatternFromPhase(obj, phase)
        % Returns pattern buffer for direct bit-writing to DMD, based on
        % phase-only data for each superpixel. The size of this matrix 
        % should be equal to resSuper. 0 <= phase <= 2*pi.
        if ~all(size(phase) == obj.resSuper)
            error('Size of phase matrix must be equal to resDMD/n.');
        end
        if any((phase(:) > 2*pi) | (phase(:) < 0))
            error('Phase must be between 0 and 2*pi.');
        end
        % Discretize phase
        p = uint32((obj.resPhase - 1)*phase/(2*pi));
        % Find pattern and return
        p1 = p(1:2:end, :); % First pixel per byte
        p2 = p(2:2:end, :); % Second pixel per byte
        for row = 0:3
            ind = obj.twoPixelPhaseRow2ind(p1, p2, row);
            obj.pattern(:, (1:4:end) + row) = obj.bytePhase(ind);   
        end
        pattern = obj.pattern;
    end
    
    function pattern = getPatternFromPhaseInd(obj, phase)
        % Returns pattern buffer for direct bit-writing to DMD, based on
        % discretized integer phase-only data for each superpixel. The size
        % of this matrix should be equal to resSuper. 
        % 0 <= phase <= resPhase - 1.
        if ~all(size(phase) == obj.resSuper)
            error('Size of field matrices must be equal to resDMD/n.');
        end
        if any((phase(:) > obj.resPhase - 1) | (phase(:) < 0))
            error('Phase must be between 0 and %d.', obj.resPhase - 1);
        end
        p = uint32(phase);
        % Find pattern and return
        p1 = p(1:2:end, :); % First pixel per byte
        p2 = p(2:2:end, :); % Second pixel per byte
        for row = 0:3
            ind = obj.twoPixelPhaseRow2ind(p1, p2, row);
            obj.pattern(:, (1:4:end) + row) = obj.bytePhase(ind);   
        end
        pattern = obj.pattern;
    end
    
    function I = getImageFromPattern(obj)
        % Returns the current pattern as a binary image.
        I = zeros(obj.resDMD, 'uint8');
        % Pattern is MSB aligned, so just shift and bit and with 1
        for i = 0:7            
            I((i + 1):8:end, :) = bitand(bitshift(obj.pattern, i - 7), 1); 
        end  
    end
    
end

end