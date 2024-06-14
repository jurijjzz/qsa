clear all
close all
clc

% Parameters
n        = 4;   % Superpixel size (only works for 4!)
resAmp   = 32;  % Amplitude resolution
resPhase = 32;  % Phase resolution

% Generate vector of fields for every pixel
v = exp(1i*2*pi*(0:(n^2 - 1))'/n^2)/n^2;

% Check n
if n ~= 4
    error('This script only works for a 4x4 superpixel!')
end

% Enumerate all fields
N = 2^(n^2);    % Number of pixel combinations
EResult = 0;
bit16EResult = uint16(0);
fprintf('Enumerating %d fields: %5d', N, 0);
for i = uint16(0:(N - 1))
    if ~mod(i, 128)
        fprintf('\b\b\b\b\b%5d', double(i) + 1);
    end
    % Sum field contributions using binary counting
    Etmp = double(bitand(bitshift(i, -(0:(n^2 - 1))), 1))*v;
    % Check if field is already on list (within rounding) and add
    diff = EResult - Etmp;
    if Etmp*conj(Etmp) > 1e-10 && ~any(diff.*conj(diff) < 1e-10)
        EResult = [EResult; Etmp];
        bit16EResult = [bit16EResult; i];
    end
end
fprintf('\b\b\b\b\b%5d', double(i) + 1);
fprintf('\nDone\n');

% Plot them
plot(real(EResult), imag(EResult), '.', 'Tag', 'manual')
xlabel('Re(E)')
ylabel('Im(E)')
axis image
xlim([-0.35, 0.35])
ylim([-0.35, 0.35])
%fixFigure(1); original code
figure(1)
set(gca, 'XTick', get(gca, 'YTick'));

%%
% Calculate 4 bit rows for every amplitude phase combination
maxAmp = max(abs(EResult));
pixelAmpPhaseRow2ind = @(a, p, row) (a + 1) + p*resAmp + row*resAmp*resPhase;
bit4AmpPhase = uint8(zeros(resAmp*resPhase*n, 1));
for a = 0:(resAmp - 1)
    for p = 0:(resPhase - 1)
        % Calculate field and find closest
        E = exp(1i*2*pi*p/resPhase)*maxAmp*a/(resAmp - 1);
        [~, I] = min(abs(EResult - E));
        bit16E = bit16EResult(I);
        % Find 4 bits for every row
        for row = 0:(n - 1)
            ind = pixelAmpPhaseRow2ind(a, p, row);
            bit4AmpPhase(ind) = bitand(bitshift(bit16E, -4*row), 15);
        end
    end
end
% showPixelAmpPhase = @(a, p) fprintf('%s\n%s\n%s\n%s\n', ...
%                                 dec2bin(bit4AmpPhase(pixelAmpPhaseRow2ind(a, p, 0)), 4), ...
%                                 dec2bin(bit4AmpPhase(pixelAmpPhaseRow2ind(a, p, 1)), 4), ...
%                                 dec2bin(bit4AmpPhase(pixelAmpPhaseRow2ind(a, p, 2)), 4), ...
%                                 dec2bin(bit4AmpPhase(pixelAmpPhaseRow2ind(a, p, 3)), 4));

% Define row shifter for row shift of pixel 2 w.r.t. pixel 1                         
rowShifterPixel2 = @(row) mod(row - 1, n); 

% % Define row shifter for row shift of two-pixel 2 w.r.t. two-pixel 1                         
% rowShifterTwoPixel2 = @(row) mod(row - 3, n) + 1; 

% Make phase only byte LUT based on 2-by-1 superpixel and n rows
twoPixelPhaseRow2ind = @(p1, p2, row) (p1 + 1) + p2*resPhase + row*resPhase^2;
bytePhase = uint8(zeros((resPhase)^2*n, 1));
for p1 = 0:(resPhase - 1)
    for p2 = 0:(resPhase - 1)        
        % Calculate and save rows        
        for row = 0:(n - 1)
            ind = twoPixelPhaseRow2ind(p1, p2, row);
            row1 = row;                     % First pixel starts with 0 phase
            row2 = rowShifterPixel2(row);   % Second pixel is one row shifted
            bit4ShiftedPixel1 = bitshift(bit4AmpPhase(pixelAmpPhaseRow2ind(resAmp - 1, p1, row1)), 4);
            bit4Pixel2 = bit4AmpPhase(pixelAmpPhaseRow2ind(resAmp - 1, p2, row2));
            bytePhase(ind) = bitor(bit4ShiftedPixel1, bit4Pixel2);
        end
    end
end
% showTwoPixelPhase = @(p1, p2) fprintf('%s\n%s\n%s\n%s\n', ...
%                 dec2bin(bytePhase(twoPixelPhaseRow2ind(p1, p2, 0)), 8), ...
%                 dec2bin(bytePhase(twoPixelPhaseRow2ind(p1, p2, 1)), 8), ...
%                 dec2bin(bytePhase(twoPixelPhaseRow2ind(p1, p2, 2)), 8), ...
%                 dec2bin(bytePhase(twoPixelPhaseRow2ind(p1, p2, 3)), 8));

% Make phase and amplitude byte LUT based on 2-by-1 superpixel and n rows
twoPixelAmpPhaseRow2ind = @(a1, a2, p1, p2, row) (a1 + 1) + a2*resAmp + ...
                    p1*resAmp^2 + p2*resAmp^2*resPhase + row*resAmp^2*resPhase^2;
byteAmpPhase = uint8(zeros((resAmp*resPhase)^2*n, 1));
for a1 = 0:(resAmp - 1)
    for a2 = 0:(resAmp - 1)   
        for p1 = 0:(resPhase - 1)
            for p2 = 0:(resPhase - 1)        
                % Calculate and save rows        
                for row = 0:(n - 1)
                    ind = twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, row);
                    row1 = row;                     % First pixel starts with 0 phase
                    row2 = rowShifterPixel2(row);   % Second pixel is one row shifted
                    bit4ShiftedPixel1 = bitshift(bit4AmpPhase(pixelAmpPhaseRow2ind(a1, p1, row1)), 4);
                    bit4Pixel2 = bit4AmpPhase(pixelAmpPhaseRow2ind(a2, p2, row2));
                    byteAmpPhase(ind) = bitor(bit4ShiftedPixel1, bit4Pixel2);
                end
            end
        end
    end
end
% showTwoPixelAmpPhase = @(a1, a2, p1, p2) fprintf('%s\n%s\n%s\n%s\n', ...
%     dec2bin(byteAmpPhase(twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, 0)), 8), ...
%     dec2bin(byteAmpPhase(twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, 1)), 8), ...
%     dec2bin(byteAmpPhase(twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, 2)), 8), ...
%     dec2bin(byteAmpPhase(twoPixelAmpPhaseRow2ind(a1, a2, p1, p2, 3)), 8));                           

% Clear unneeded variables
clear a a1 a2 bit16E bit4Pixel2 bit4ShiftedPixel1 diff E Etmp i I ind N p p1 p2 row row1 row2 v
save('LUT')