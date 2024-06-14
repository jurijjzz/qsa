clear all
close all
clc

% Load DMD and constants
D = DMD.getInstance;
C = D.C;

% Get device ID
DevId = D.DeviceId(1);

% Allocate 100 binary images
SeqId = D.AlpSeqAlloc(DevId, 1, 1000);

% Make both bit and byte array
bitArray  = randi([0, 255], 1024/8, 768, 1000, 'uint8');
byteArray = randi([0, 1], 1024, 768, 1000, 'uint8');
byteArray = typecast(byteArray(:), 'uint64');

% Put to bit mode and time writing
D.AlpSeqControl(DevId, SeqId, C.ALP_DATA_FORMAT, C.ALP_DATA_BINARY_TOPDOWN);
tic;
D.AlpSeqPut(DevId, SeqId, 0, 1000, bitArray);
toc

% Put to byte mode and time writing
D.AlpSeqControl(DevId, SeqId, C.ALP_DATA_FORMAT, C.ALP_DATA_LSB_ALIGN);
tic;
D.AlpSeqPut(DevId, SeqId, 0, 1000, byteArray);
toc

% Close everything properly
D.delete;