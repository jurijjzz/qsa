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

# width = 1024
# height = 768
width = dev.width
height = dev.height

cell = 128
lg2_c = np.log2(cell)
assert abs(lg2_c - round(lg2_c)) < 1e-6, "Cell size is not a power of 2"

seqs = []
white = np.ones((1, height, width), dtype=np.uint8)
for i in range(height // cell):
    for j in range(width // cell):
        img = white.copy()

        img[0, cell * i:cell * (i + 1), cell * j:cell * (j + 1)] = 0

        seq = dev.make_sequence(bit_planes=1, pic_num=1)
        seq[SequenceControl.DataFormat] = SequenceValue.DataLSB
        seq.put(img.data)
        seq.timing(picture_time=10000)

        seqs.append(seq)


for i, seq in enumerate(cycle(seqs)):
    alp42.start_projection(seq, cont=True)
    if i < len(seqs):
        camera.start()
        camera.take_picture(f"imgs/pixel_size {cell};row {i // 8 + 1};column {i % 8 + 1}.png")
    else:
        command = input()
        if command.startswith('q'):
            break
        print("\033[A\033[0K", end='')
        
