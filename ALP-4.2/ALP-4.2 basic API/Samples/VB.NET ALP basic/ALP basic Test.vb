Imports VB_NET_ALP_basic.ALP_basic_Import

Public Class ALP_basic_Test
    Private Function AlpBasicErrorString(ByVal nRet As Int32) As String
        ' See also the C header file "alp.h" for values of the return codes.
        ' This file also contains the values of other control types and
        ' special values.
        Select Case nRet
            Case AlpBasicReturnCodes.ALPB_SUCCESS
                AlpBasicErrorString = "ALPB_SUCCESS"
            Case AlpBasicReturnCodes.ALPB_SUCC_PARTIAL
                AlpBasicErrorString = "ALPB_SUCC_PARTIAL"
            Case AlpBasicReturnCodes.ALPB_ERROR
                AlpBasicErrorString = "ALPB_ERROR"
            Case AlpBasicReturnCodes.ALPB_ERR_NOT_FOUND
                AlpBasicErrorString = "ALPB_ERR_NOT_FOUND"
            Case AlpBasicReturnCodes.ALPB_ERR_DUPLICATE
                AlpBasicErrorString = "ALPB_ERR_DUPLICATE"
            Case AlpBasicReturnCodes.ALPB_ERR_INIT
                AlpBasicErrorString = "ALPB_ERR_INIT"
            Case AlpBasicReturnCodes.ALPB_ERR_RESET
                AlpBasicErrorString = "ALPB_ERR_RESET"
            Case AlpBasicReturnCodes.ALPB_ERR_HDEVICE
                AlpBasicErrorString = "ALPB_ERR_HDEVICE"
            Case AlpBasicReturnCodes.ALPB_ERR_DISCONNECT
                AlpBasicErrorString = "ALPB_ERR_DISCONNECT"
            Case AlpBasicReturnCodes.ALPB_ERR_CONNECTION
                AlpBasicErrorString = "ALPB_ERR_CONNECTION"
            Case AlpBasicReturnCodes.ALPB_ERR_MT
                AlpBasicErrorString = "ALPB_ERR_MT"
            Case AlpBasicReturnCodes.ALPB_ERR_HALT
                AlpBasicErrorString = "ALPB_ERR_HALT"
            Case AlpBasicReturnCodes.ALPB_ERR_MEM
                AlpBasicErrorString = "ALPB_ERR_MEM"
            Case AlpBasicReturnCodes.ALPB_ERR_MEM_I
                AlpBasicErrorString = "ALPB_ERR_MEM_I"
            Case AlpBasicReturnCodes.ALPB_ERR_PARAM
                AlpBasicErrorString = "ALPB_ERR_PARAM"
            Case AlpBasicReturnCodes.ALPB_ERR_DONGLE
                AlpBasicErrorString = "ALPB_ERR_DONGLE"
            Case Else
                AlpBasicErrorString = "(unknown error 0x" & Hex(nRet) & ")"
        End Select
        Return AlpBasicErrorString & " (" & AlpbDllGetResultText(nRet) & ")"
    End Function


    Private m_bInitialized As Boolean = False, _
        m_AlpDeviceId As Int32, m_DmdType As AlpBasicDmdTypes
    Private Sub Alloc_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Alloc.Click
        Dim nRet As Int32
        Dim nSerial As UInt32 = 0

        If m_bInitialized Then
            MessageBox.Show("ALP basic already allocated")
            Exit Sub
        End If

        ' Allocate ALP device (no precautions if already allocated!)

        ' Known Errors:
        ' System.DllNotFoundException -> ALP DLL must be available, e.g. in the same directory as this exe file
        ' System.BadImageFormatException -> ALP DLL platform does not match. Try the Win32 (x86) or the x64 version.
        nRet = AlpbDevAlloc(0, m_AlpDeviceId)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevAlloc Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

        nRet = AlpbDevInquire(m_AlpDeviceId, AlpBasicDevTypes.ALPB_DEV_SERIAL, nSerial)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevInquire(ALPB_DEV_SERIAL) Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
        End If

        nRet = AlpbDevInquire(m_AlpDeviceId, AlpBasicDevTypes.ALPB_DEV_DMDTYPE, m_DmdType)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevInquire(ALPB_DEV_DMDTYPE) Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            AlpbDevFree(m_AlpDeviceId)
            Exit Sub
        End If

        m_bInitialized = True
        MessageBox.Show("Success." & vbCrLf & _
            "Allocated ALP basic device." & vbCrLf & _
            "Serial Number:" & Format(nSerial) & vbCrLf & _
            "DMD Type: " & [Enum].GetName(GetType(AlpBasicDmdTypes), m_DmdType))
    End Sub

    Private Sub Free_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Free.Click
        Dim nRet As Int32

        If Not m_bInitialized Then
            MessageBox.Show("ALP basic not allocated")
            Exit Sub
        End If

        ' Halt ALP device (no precautions if not allocated!)
        nRet = AlpbDevControl(m_AlpDeviceId, AlpBasicDevTypes.ALPB_DEV_HALT, 1)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevControl(ALPB_DEV_HALT)  Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If
        ' Free ALP device
        nRet = AlpbDevFree(m_AlpDeviceId)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevFree Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

        m_bInitialized = False
        MessageBox.Show("Success." & vbCrLf & _
            "Halted and released ALP basic device.")
    End Sub

    Private Sub Pattern1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Pattern1.Click
        Dim nRet As Int32
        Dim nSizeX As UInt32, nSizeY As UInt32

        If Not m_bInitialized Then
            MessageBox.Show("ALP basic not allocated")
            Exit Sub
        End If

        Select Case m_DmdType
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_1080P_095A, AlpBasicDmdTypes.ALPB_DMDTYPE_DISCONNECT
                nSizeX = 1920
                nSizeY = 1080
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_WUXGA_096A
                nSizeX = 1920
                nSizeY = 1200
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_XGA, AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_055A, _
                AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_055X, AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_07A
                nSizeX = 1024
                nSizeY = 768
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_SXGA_PLUS
                nSizeX = 1400
                nSizeY = 1050
            Case Else
                MessageBox.Show("DMD type not supported: " & Format(m_DmdType))
                Exit Sub
        End Select

        ' Generate image data: (checkered pattern, 64x64 squares)
        Dim Pattern(nSizeX * nSizeY) As Byte, x As Int32, y As Int32
        For y = 0 To nSizeY - 1 Step 1
            For x = 0 To nSizeX - 1 Step 1
                If ((x Xor y) And 64) = 0 Then
                    Pattern(y * nSizeX + x) = 255
                Else
                    Pattern(y * nSizeX + x) = 0
                End If
            Next
        Next

        ' Send binary image to DMD memory
        nRet = AlpbDevLoadRows(m_AlpDeviceId, Pattern, 0, nSizeY - 1)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevLoadRows Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

        ' Reset micro-mirrors according to previously loaded image data
        nRet = AlpbDevReset(m_AlpDeviceId, ResetTypes.ALPB_RESET_GLOBAL, 0)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevReset Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

    End Sub

    Private Sub Pattern2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Pattern2.Click
        Dim nRet As Int32
        Dim nSizeX As UInt32, nSizeY As UInt32

        If Not m_bInitialized Then
            MessageBox.Show("ALP basic not allocated")
            Exit Sub
        End If

        Select Case m_DmdType
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_1080P_095A, AlpBasicDmdTypes.ALPB_DMDTYPE_DISCONNECT
                nSizeX = 1920
                nSizeY = 1080
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_WUXGA_096A
                nSizeX = 1920
                nSizeY = 1200
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_XGA, AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_055A, _
                AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_055X, AlpBasicDmdTypes.ALPB_DMDTYPE_XGA_07A
                nSizeX = 1024
                nSizeY = 768
            Case AlpBasicDmdTypes.ALPB_DMDTYPE_SXGA_PLUS
                nSizeX = 1400
                nSizeY = 1050
            Case Else
                MessageBox.Show("DMD type not supported: " & Format(m_DmdType))
                Exit Sub
        End Select

        ' Generate image data: (checkered pattern, 128x128 squares)
        Dim Pattern(nSizeX * nSizeY) As Byte, x As Int32, y As Int32
        For y = 0 To nSizeY - 1 Step 1
            For x = 0 To nSizeX - 1 Step 1
                If ((x Xor y) And 128) = 0 Then
                    Pattern(y * nSizeX + x) = 255
                Else
                    Pattern(y * nSizeX + x) = 0
                End If
            Next
        Next

        ' Send binary image to DMD memory
        nRet = AlpbDevLoadRows(m_AlpDeviceId, Pattern, 0, nSizeY - 1)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevLoadRows Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

        ' Reset micro-mirrors according to previously loaded image data
        nRet = AlpbDevReset(m_AlpDeviceId, ResetTypes.ALPB_RESET_GLOBAL, 0)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevReset Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

    End Sub

    Private Sub Clear_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Clear.Click
        Dim nRet As Int32

        If Not m_bInitialized Then
            MessageBox.Show("ALP basic not allocated")
            Exit Sub
        End If

        ' Send binary image to DMD memory
        nRet = AlpbDevClear(m_AlpDeviceId, 0, 15)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevClear Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

        ' Reset micro-mirrors according to previously loaded image data
        nRet = AlpbDevReset(m_AlpDeviceId, ResetTypes.ALPB_RESET_GLOBAL, 0)
        If nRet <> 0 Then
            MessageBox.Show("AlpbDevReset Error" & _
                vbCrLf & AlpBasicErrorString(nRet))
            Exit Sub
        End If

    End Sub
End Class
