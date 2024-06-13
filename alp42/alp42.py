import os
import platform
from functools import wraps

import ctypes
from ctypes import c_long, c_uint32, c_uint8, pointer

from enum import Enum

from .alp_exceptions import *


class InquireType(Enum):
    DeviceNumber = 2000
    Width = 2058
    Height = 2057
    Version = 2001
    AvailableMemory = 2003
    SynchPolarity = 2004
    TriggerEdge = 2005
    DevDMDType = 2021


class ControlType(Enum):
    SynchPolarity = 2004
    TriggerEdge = 2005
    USBConnection = 2016


class ControlValue(Enum):
    Default = 0
    LevelHigh = 2006
    LevelLow = 2007
    EedgeFalling = 2009
    EedgeRising = 2008


class SequenceControl(Enum):
    Repeat = 2100
    FirstFrame = 2101
    LastFrame = 2102
    DataFormat = 2110
    PicNum = 2201


class SequenceValue(Enum):
    Default = 0
    DataMSB = 0
    DataLSB = 1
    DataBinaryTopDown = 2
    DataBinaryBottomUp = 3

if platform.system() != 'Windows':
    raise ImportError("ALP4.2 is only available on Windows")

os.add_dll_directory(os.path.abspath(os.path.curdir))
_alp_lib = ctypes.CDLL("alpV42.dll")
AlpID = c_uint32


def _check_errors(res: int):
    match res:
        case 0: pass
        case 1001: raise NotOnline
        case 1002: raise NotIdle
        case 1003: raise NotAvailable
        case 1004: raise NotReady
        case 1005: raise ParamInvalid
        case 1006: raise AddressInvalid
        case 1007: raise MemoryFull
        case 1008: raise SeqInUse
        case 1009: raise Halted
        case 1010: raise ErrorInit
        case 1011: raise ErrorComm
        case 1012: raise DeviceRemoved
        case 1013: raise NotConfigured
        case 1018: raise ErrorPowerDown


def _api_cache(method):
    res = None

    @wraps
    def _method(self):
        nonlocal res
        
        if res is None:
            res = method(self)
        return res

    return _method


class Device:

    def __init__(self, device_num: int, init_flag: int):
        self._device_id = AlpID(0)
        res = _alp_lib.AlpDevAlloc(
            c_long(device_num),
            c_long(init_flag),
            pointer(self._device_id)
        )
        _check_errors(res)

    def __setitem__(self, key: ControlType, value: ControlValue):
        res = _alp_lib.AlpDevControl(
            self._device_id,
            c_long(key.value),
            c_long(value.value)
        )
        # _check_errors(int(res))

    def __getitem__(self, key: InquireType) -> int:
        res = c_long(0)
        api_res = _alp_lib.AlpDevInquire(
            self._device_id,
            c_long(key.value),
            pointer(res)
        )
        # _check_errors(int(api_res, base=10))
        return res.value

    @property
    @_api_cache
    def width(self) -> int:
        return self[InquireType.Width]

    @property
    @_api_cache
    def height(self) -> int:
        return self[InquireType.Height]

    def halt(self):
        res = _alp_lib.AlpDevHalt(self._device_id)
        # _check_errors(int(res))

    def __del__(self):
        res = _alp_lib.AlpDevFree(self._device_id)
        # _check_errors(int(res))

    def make_sequence(self, bit_planes: int, pic_num: int) -> 'Sequence':
        return Sequence(self, bit_planes, pic_num)


class Sequence:

    def __init__(self, device: Device, bit_planes: int, pic_num: int):
        self._seq_id = AlpID(0)
        self._device_id = device._device_id
        # TODO: Check available memory for amount of images
        res = _alp_lib.AlpSeqAlloc(
            self._device_id,
            c_long(bit_planes),
            c_long(pic_num),
            pointer(self._seq_id)
        )
        # _check_errors(int(res, base=10))

    def __setitem__(self, key: SequenceControl, value: SequenceValue | int):
        if isinstance(value, SequenceValue):
            value = value.value
        res = _alp_lib.AlpSeqControl(
            self._device_id,
            self._seq_id,
            c_long(key.value),
            c_long(value)
        )
        # _check_errors(int(res, base=10))

    def __getitem__(self, key: SequenceControl) -> int:
        res = c_long(0)
        api_res = _alp_lib.AlpSeqInquire(
            self._device_id,
            self._seq_id,
            c_long(key.value),
            pointer(res)
        )
        # _check_errors(int(api_res, base=10))
        return res.value

    def timing(self, illuminate_time=0, picture_time=0,
               synch_delay=0, synch_pulse_width=0, trigger_in_delay=0):
        # TODO: Add constraint checks
        res = _alp_lib.AlpSeqTiming(
            self._device_id, self._seq_id,
            c_long(illuminate_time),
            c_long(picture_time),
            c_long(synch_delay),
            c_long(synch_pulse_width),
            c_long(trigger_in_delay))
        # _check_errors(int(res, base=10))

    def put(self, pics: memoryview, offset=0):
        if pics.ndim != 3:
            raise ValueError(f"Expected 3 dimensional array, got {pics.ndim}")

        if pics.shape is None:
            raise ValueError

        n_pics = pics.shape[0]
        # if pics.shape[1] != 

        # I have no idea if it will work
        array = (c_uint8 * pics.nbytes)(*pics.tobytes())
        res = _alp_lib.AlpSeqPut(
            self._device_id,
            self._seq_id,
            c_long(offset),
            c_long(n_pics), array
        )
        # _check_errors(int(res, base=10))

    def __del__(self):
        res = _alp_lib.AlpSeqFree(self._device_id, self._seq_id)
        # _check_errors(int(res, base=10))


def start_projection(seq: Sequence, cont=False):
    if cont:
        res = _alp_lib.AlpProjStartCont(seq._device_id, seq._seq_id)
    else:
        res = _alp_lib.AlpProjStart(seq._device_id, seq._seq_id)
    # _check_errors(int(res, base=10))


def halt_projection(seq: Sequence):
    res = _alp_lib.AlpProjHalt(seq._device_id)
    # _check_errors(int(res, base=10))
