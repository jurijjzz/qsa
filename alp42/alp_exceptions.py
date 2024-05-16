class AlpException(Exception):
    pass


class NotOnline(AlpException):
    pass


class NotIdle(AlpException):
    pass


class NotAvailable(AlpException):
    pass


class NotReady(AlpException):
    pass


class ParamInvalid(AlpException):
    pass


class AddressInvalid(AlpException):
    pass


class MemoryFull(AlpException):
    pass


class SeqInUse(AlpException):
    pass


class Halted(AlpException):
    pass


class ErrorInit(AlpException):
    pass


class ErrorComm(AlpException):
    pass


class DeviceRemoved(AlpException):
    pass


class NotConfigured(AlpException):
    pass


class ErrorPowerDown(AlpException):
    pass
