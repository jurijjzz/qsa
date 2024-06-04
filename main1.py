import os
import sys
from itertools import cycle

import cv2 as cv
import numpy as np

import alp42
from alp42 import (
    Device, ControlType, InquireType, ControlValue,
    Sequence, SequenceControl, SequenceValue
)


os.add_dll_directory("C:/Program Files/Teledyne/Spinnaker/bin64/vs2015")
import camera


dev = Device(0, 0)
camera.start()

print(dev[InquireType.DeviceNumber])
print(dev[InquireType.DevDMDType])
print(dev[InquireType.AvailableMemory])

# width = dev.width
# height = dev.height
width = 1024
height = 768

x0, x1 = 235, 660
y0, y1 = 133, 558
cell = 128

# seqs = []
img = np.ones((1, height, width), dtype=np.uint8)
# for i in range((y1 - y0) // cell):
#     for j in range((x1 - x0) // cell):
#         pattern = np.ones((y1 - y0, x1 - x0), dtype=np.uint8)
#         pattern[cell * i:cell * (i + 1), cell * j:cell * (j + 1)] = 0

#         img[0, x0:x1, y0:y1] = pattern

#         seq = dev.make_sequence(bit_planes=1, pic_num=1)
#         seq[SequenceControl.DataFormat] = SequenceValue.DataLSB
#         seq.put(img.data)
#         seq.timing(picture_time=10000)

#         seqs.append(seq)

# Write checkboard pattern
seqs = []
pattern = np.ones((height, width), dtype=np.uint8)
for i in range(height // cell):
    for j in range(width // cell):
        pattern[cell * i:cell * (i + 1), cell * j:cell * (j + 1)] = (i + j) % 2

img[0] = pattern

seq = dev.make_sequence(bit_planes=1, pic_num=1)
seq[SequenceControl.DataFormat] = SequenceValue.DataLSB
seq.put(img.data)
seq.timing(picture_time=10000)
seqs.append(seq)

pattern = np.ones((height, width), dtype=np.uint8)
for i in range(height // cell):
    for j in range(width // cell):
        pattern[cell * i:cell * (i + 1), cell * j:cell * (j + 1)] = (i + j) % 2 == 0

img[0] = pattern

seq = dev.make_sequence(bit_planes=1, pic_num=1)
seq[SequenceControl.DataFormat] = SequenceValue.DataLSB
seq.put(img.data)
seq.timing(picture_time=10000)
seqs.append(seq)

# img[0, x0:x1, y0:y1] = pattern

# seq = dev.make_sequence(bit_planes=1, pic_num=1)
# seq[SequenceControl.DataFormat] = SequenceValue.DataLSB

# seq.put(img.data)

# seq.timing(picture_time=10000)
# seqs.append(seq)

camera.take_picture("imgs/clear0.png")
for i in range(10):
    for j, seq in enumerate(seqs):
        alp42.start_projection(seq, cont=True)
        camera.take_picture(f"imgs/{j}-{i}.png")

# for i, seq in enumerate(cycle(seqs)):
#     alp42.start_projection(seq, cont=True)
#     if i < len(seqs):
#         camera.start()
#         camera.take_picture(f"imgs/pixel_size {cell};row {i // ((y1 - y0) // cell) + 1};column {i % ((y1 - y0) // cell) + 1}.png")
#     else:
#         command = input()
#         if command.startswith('q'):
#             break
#         print("\033[A\033[0K", end='')

