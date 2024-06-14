This is a part of the ALP basic application programming interface (API).
Copyright (C) 2004-2013 ViALUX GmbH
All rights reserved.
This C++ programming sample is provided as-is, without any warranty.

Please always consult the ALP basic API description when customizing
this program. It contains a detailled specification of all
Alpb... functions.

Sample application:
===================
This is a small sample application showing how to use the ALP basic API.

It generates and displays three binary images: horizontal and vertical bars
(32 pixels wide) and a checkered pattern (32x32).
They are displayed in an alternating sequence, and then all three images
are combined by partitioning the DMD area into 3 horizontal stripes.

Finally the DMD is cleared block by block (bottom-up).

DMD type support:
=================
This sample application takes advantage of the DDC4100 feature to detect the
DMD type. It inquires this information from the ALP basic API and
automatically generates proper image and control data.

Command line arguments:
=======================
(no command line evaluation)

Used functions:
===============
The program demonstrates the usage of the following ALP API functions:
AlpbDevAlloc
AlpbDevControl
AlpbDevInquire
AlpbDevLoadRows
AlpbDevReset
AlpbDevClear
AlpbDevFree
AlpbDllGetResultText


Compile and Run:
================
There are configurations available for Microsoft® Visual Studio® 2005 and
for Visual Studio 2010. Just open the according .sln file, and use the
Build command in order to compile the project.

When using another compiler please make sure that the file alpbasic.h can be
found by the compiler. AlpV42basic.lib must be linked to the application.

Example:

rem Compile:
set include=..;C:\Program Files\Microsoft Visual Studio\VC98\INCLUDE
set lib=..;C:\Program Files\Microsoft Visual Studio\VC98\LIB
cl /Fe"CPP ConsoleSample ALP basic.exe" "CPP ConsoleSample ALP basic.cpp" /link alpV42basic.lib

At runtime, the alpV42basic.dll must be accessible. For example, put it into
the same directory as the "CPP ConsoleSample ALP basic.exe".

Note that the DLL must match the EXE file regarding the processor platform:
mixing x64 and win32 will inhibit the program start.

