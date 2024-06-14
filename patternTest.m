clear all
close all
clc

% Instantiate pattern generator
P = DMDpattern(1024, 768);

% Test field pattern
TAmpPhase = 0;
TPhase = 0;
for i = 1:4000
amplitude = randi([0, 31], P.resSuper, 'uint32');
phase = randi([0, 31], P.resSuper, 'uint32');
t1 = tic;
pattern = P.getPatternFromFieldInd(amplitude, phase);
TAmpPhase = TAmpPhase + toc(t1);
% t1 = tic;
% pattern = P.getPatternFromPhase(phase);
% TPhase = TPhase + toc(t1);
end


p = 2*pi/32*ones(P.resSuper);
p(1:10, 1:10) = pi;
P.getPatternFromPhase(p);
I = P.getImageFromPattern();
figure
imagesc(I')
axis image