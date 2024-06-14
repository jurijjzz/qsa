' *********************************************************************************
' *                                                                               *
' *   Project:      ALP basic                                                     *
' *   Filename:     ALP basic Import.vb : DLL Import Class for Visual Basic® 2005 *
' *                                                                               *
' *********************************************************************************
' *                                                                               *
' *   © 2008 ViALUX GmbH. All rights reserved.                                    *
' *                                                                               *
' *                                                                               *
' *   This software is provided 'as-is', without any express or implied           *
' *   warranty.  In no event will the authors be held liable for any damages      *
' *   arising from the use of this software.                                      *
' *                                                                               *
' *   Permission to use this software is granted to anyone who has purchased      *
' *   an ALP basic or ALP high-speed of any version.                              *
' *   This permission includes to use this software for any purpose, including    *
' *   commercial applications, and to alter it freely. Redistribution of the      *
' *   source code is prohibited.                                                  *
' *                                                                               *
' *   Please always consult the ALP basic API description when                    *
' *   customizing this program. It contains a detailled specification             *
' *   of all Alpb... functions.                                                   *
' *                                                                               *
' *********************************************************************************
' *                                                                               *
' *   Version:        5                                                           *
' *                                                                               *
' *********************************************************************************

' Required in order to call DLL functions
Imports System.Runtime.InteropServices

' Please define a public constant string AlpDllFileName in
' the module AlpDllFileName. It shall contain the file name of the
' ALP basic API DLL.
Imports VB_NET_ALP_basic.AlpDllFileName

Public Class ALP_basic_Import
    ' Type ALPB_HDEVICE is Int32
    Private Const DllCallingConvention As CallingConvention = CallingConvention.Cdecl

    Public Const ALP_DEFAULT As Int32 = 0

    Enum AlpBasicReturnCodes As Int32
        ALPB_SUCCESS = 0
        ALPB_SUCC_PARTIAL = 1
        ALPB_ERROR = &H80000000             ' generic error, e.g. "not implemented"; should never be returned to user
        ALPB_ERR_NOT_FOUND = &H80000001     ' DevAlloc: serial number not found
        ALPB_ERR_DUPLICATE = &H80000002     ' DevAlloc: device already allocated
        ALPB_ERR_INIT = &H80000003          ' DevAlloc: initialization error
        ALPB_ERR_RESET = &H80000004         ' DevAlloc: init. error, maybe due to reset switch
        ALPB_ERR_HDEVICE = &H80000005
        ALPB_ERR_DISCONNECT = &H80000006
        ALPB_ERR_CONNECTION = &H80000007    ' connection error occurred, but device is (maybe) re-connected
        ALPB_ERR_MT = &H80000008
        ALPB_ERR_HALT = &H80000009
        ALPB_ERR_MEM = &H8000000A
        ALPB_ERR_MEM_I = &H8000000B
        ALPB_ERR_PARAM = &H8000000C
        ALPB_ERR_DONGLE = &H8000000D
        ALPB_ERR_API_DLL_MISSING = &H8000000E
        ALPB_ERR_API_DLL_UNKNOWN = &H8000000F
    End Enum

    Enum AlpBasicDllTypes As Int32                  ' AlpbDllInquire and AlpbDllControl - ControlTypes
        ALPB_DLL_TIMEOUT = 0
        ALPB_DLL_VERSION = 1
        ALPB_DLL_DEV_VERSIONS = 2
    End Enum

    Enum AlpBasicDevTypes As Int32                  ' AlpbDevInquire and AlpbDevControl - ControlTypes
        ALPB_DEV_HALT = 0
        ALPB_DEV_DRIVER_VER = 1
        ALPB_DEV_FIRMWARE_DATE = 2
        ALPB_DEV_CONFIG_DATE = 3
        ALPB_DEV_SERIAL = 4
        ALPB_DEV_DMDTYPE = 5
        ALPB_DEV_VERSION = 6
        ALPB_DEV_DDC_VERSION = 7
        ALPB_DEV_SWITCHES = 8
        ALPB_DEV_DDC_SIGNALS = 9
    End Enum

    Enum AlpBasicDmdTypes As Int32                  ' ALPB_DEV_DMDTYPE - Values
        ALPB_DMDTYPE_INVALID = 0
        ALPB_DMDTYPE_XGA = 1
        ALPB_DMDTYPE_SXGA_PLUS = 2
        ALPB_DMDTYPE_1080P_095A = 3         ' (1080P 0.95" Type A)
        ALPB_DMDTYPE_XGA_07A = 4            ' (XGA .7" Type A) 
        ALPB_DMDTYPE_XGA_055A = 5           ' (XGA .55" Type A) 
        ALPB_DMDTYPE_XGA_055X = 6           ' (XGA .55" Type X)
        ALPB_DMDTYPE_WUXGA_096A = 7         ' (WUXGA .96" Type A)

        ALPB_DMDTYPE_DISCONNECT = 255       ' DMD type not recognized,
        ' or no DMD connected, this behaves like 1080p by default
    End Enum

    Enum ResetTypes As Int32
        ALPB_RESET_SINGLE = 0
        ALPB_RESET_PAIR = 1
        ALPB_RESET_QUAD = 2
        ALPB_RESET_GLOBAL = 4
    End Enum

    Enum AlpBasicSpecialValues As Int32
        ALPB_INFINITE = &HFFFFFFFF
    End Enum

    <StructLayout(LayoutKind.Sequential)> Public Structure ALPB_VERSION
        Public Version1 As Int16
        Public Version2 As Int16
        Public Version3 As Int16
        Public Build As Int16
        Overrides Function ToString() As String
            Return Str(Version1) & "." & Str(Version2) & "." & Str(Version3) & "." & Str(Build)
        End Function
    End Structure

    <StructLayout(LayoutKind.Sequential)> Structure ALPB_DATE
        Public Year As Int16                   ' year AD
        Public Month As Int16                  ' month: 1..12
        Public Day As Int16                    ' day of month: 1..31
        Function ToDate() As Date
            Return New Date(Year, Month, Day)
        End Function
        Public Overrides Function ToString() As String
            Return ToDate().ToString()
        End Function
    End Structure

    ' Declare a prototype for each DLL function you want to use

    ' Known Errors:
    ' System.DllNotFoundException -> ALP DLL must be available, e.g. in the same directory as this exe file
    ' System.BadImageFormatException -> ALP DLL platform does not match. Try the Win32 (x86) or the x64 version.

    ' return SUCCESS, ERR_MT, ERR_MEM, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDllControl")> Public Overloads Shared Function _
    AlpbDllControl _
        (ByVal ControlType As AlpBasicDllTypes, ByRef pValue As Int32) _
        As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_MT, ERR_MEM, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDllInquire")> Public Overloads Shared Function _
    AlpbDllInquire _
        (ByVal QueryType As AlpBasicDllTypes, ByRef pValue As Int32) As AlpBasicReturnCodes
    End Function
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDllInquire")> Public Overloads Shared Function _
    AlpbDllInquire _
        (ByVal QueryType As AlpBasicDllTypes, ByRef pValue As ALPB_VERSION) As AlpBasicReturnCodes
    End Function

    ' Wrap special marshal behaviour regarding strings.
    ' Call the DLL function and return either 'Nothing' on error, or the string from the DLL.
    Public Shared Function AlpbDllGetResultText(ByVal RetVal As AlpBasicReturnCodes) As String
        Dim Length As Int32 = 100
        Dim text As System.Text.StringBuilder = New System.Text.StringBuilder(Length)
        Dim Ret As AlpBasicReturnCodes
        Ret = AlpbDllGetResultText(RetVal, Length, text)
        If (Ret < 0) Then
            Return Nothing
        ElseIf (Ret = AlpBasicReturnCodes.ALPB_SUCC_PARTIAL) Then
            text = New System.Text.StringBuilder(Length)
            Ret = AlpbDllGetResultText(RetVal, Length, text)
        End If
        Return text.ToString
    End Function
    ' return SUCCESS, SUCC_PARTIAL, ERR_MEM, or ERR_PARAM
    ' See also The other implementation of AlpbDllGetResultText
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDllGetResultText")> Public Shared Function _
    AlpbDllGetResultText _
        (ByVal RetVal As AlpBasicReturnCodes, ByRef pSize As Int32, _
         <Out()> ByVal pStr As System.Text.StringBuilder) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_INIT, ERR_INIT_DUP, ERR_MT, or ERR_MEM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevAlloc")> Public Shared Function AlpbDevAlloc _
        (ByVal nSerial As UInt32, ByRef hDevice As Int32) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, ERR_DISCONNECT, ERR_CONNECTION, ERR_MT, ERR_MEM, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevControl")> Public Overloads Shared Function _
    AlpbDevControl _
        (ByVal hDevice As Int32, ByVal ControlType As AlpBasicDevTypes, _
        ByRef pValue As Int32) As AlpBasicReturnCodes
    End Function
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevControl")> Public Overloads Shared Function _
    AlpbDevControl _
        (ByVal hDevice As Int32, ByVal ControlType As AlpBasicDevTypes, _
        ByRef pValue As AlpBasicDmdTypes) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, ERR_DISCONNECT, ERR_CONNECTION, ERR_MT, ERR_MEM, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevInquire")> Public Overloads Shared Function _
    AlpbDevInquire _
        (ByVal hDevice As Int32, ByVal QueryType As AlpBasicDevTypes, _
        ByRef pValue As Int32) As AlpBasicReturnCodes
    End Function
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevInquire")> Public Overloads Shared Function _
    AlpbDevInquire _
        (ByVal hDevice As Int32, ByVal QueryType As AlpBasicDevTypes, _
        ByRef pValue As ALPB_DATE) As AlpBasicReturnCodes
    End Function
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevInquire")> Public Overloads Shared Function _
    AlpbDevInquire _
        (ByVal hDevice As Int32, ByVal QueryType As AlpBasicDevTypes, _
        ByRef pValue As ALPB_VERSION) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, or ERR_MT
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevFree")> Public Shared Function AlpbDevFree _
        (ByVal hDevice As Int32) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, ERR_DISCONNECT, ERR_CONNECTION, ERR_MT, ERR_HALT, ERR_MEM, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevLoadRows")> Public Shared Function AlpbDevLoadRows _
        (ByVal hDevice As Int32, ByVal pImage As Byte(), _
        ByVal FirstRow As Int32, ByVal LastRow As Int32) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, ERR_DISCONNECT, ERR_CONNECTION, ERR_MT, ERR_HALT, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevClear")> Public Shared Function AlpbDevClear _
        (ByVal hDevice As Int32, ByVal FirstBlock As Int32, _
        ByVal LastBlock As Int32) As AlpBasicReturnCodes
    End Function

    ' return SUCCESS, ERR_HDEVICE, ERR_DISCONNECT, ERR_CONNECTION, ERR_MT, ERR_HALT, or ERR_PARAM
    <DllImport(AlpDllFileName.AlpDllFileName, CallingConvention:=DllCallingConvention, _
    EntryPoint:="AlpbDevReset")> Public Shared Function AlpbDevReset _
        (ByVal hDevice As Int32, ByVal ResetType As ResetTypes, _
        ByVal ResetAddr As Int32) As AlpBasicReturnCodes
    End Function

End Class
