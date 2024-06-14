This Programming Sample is part of the ALP high-speed API.
It is provided as-is, without any warranty.
Copyright (C) 2013 ViALUX GmbH
All rights reserved.

Please always consult the ALP-4 high-speed API description when customizing
this program. It contains a detailled specification of all Alp... functions.

------------------------------------------------------------------------
ALP LED API Sample Multi-Color:

The intention is to show ALP users an example how to use the ALP LED API
programmatically. A very interactive way for examining the behavior of this
API is using the ALP high-speed Demo application.

Note that even though the sample has been written using C++, it could also
be a good reference for those who use other programming languages. Please
read the file "ALP LED API Sample Multi-Color.cpp" in a text editor,
preferable one with syntax high-lighting (e.g. VIM). It contains
descriptive comments, and control flow is quite clear. We have tried to
emphasize the actual ALP commands while out-sourcing much stuff like error
handling and user interface. But be aware that this Multi-Color sample is
fairly complex compared to the Single-Color version. So it is recommended
to study the Single-Color sample first (even though it won't work with
triggered light-sources like in multi-color projectors).

"Single-Color" stands for the assumption that only one LED is connected
to the ALP. This LED is usually not synchronized to image display.
This is in contrast to "Multi-Color" systems, where Gated Synchronization
Ports must be used for switching LEDs on a frame-by-frame basis.

Tasks:
- Initialize the ALP device.
- Initialize a sequence and download generated images. They contain
  a bright square that travels from top-left to bottom-right corner
  of the DMD.
  The user can choose low-speed (5Hz) or high-speed (500Hz) display.
- Ask the user three times for LED type and brightness (percentage).
  (ESC allows to avoid using one of the LEDs)
- Initialize these LEDs and set up this brightness.
- Initialize the Gated Synch signal of each LED
  (round-robin, but its period aligns with the display sequence, so each
  square is displayed with a constant color)
- Monitor each LEDs current and temperature, stopping at a
  threshold temperature (Note: This program does not derive this
  threshold value from the selected LED type. This is just
  a demonstration of how temperature supervision could be done.)
- Check result of all ALP API calls (VERIFY_ALP macro) and quit
  in case of error.

Note on temperature monitor:
The model for calculating the LED (junction) temperature is based on
a thermistor (senses reference temperature) and the dissipated electrical
power. This makes it sensitive to changes in forward current.
The ALP LED API cannot take these changes into account (settling, duty cycle
in pulsed mode) and so it calculates based upon the last known (measured)
LED current. This results in fast changes in junction temperature reading.
That's why this sample additionally reports reference temperature.

Note on gated synch signals:
If one LED shall be permanently on, then this can be achieved by a trick.
Enable the gated synch signal of this LED driver by setting Period=1.
Make the gate always closed (Gate[0]=0) and set it low-active (Polarity=0).
This way, the output continuously drives its inactive value, i.e. "high",
switching the LED on.


------------------------------------------------------------------------
Below follows an automatic comment of Microsoft Visual Studio 2010,
generated when creating this project.

========================================================================
    CONSOLE APPLICATION : ALP LED API Sample Single-Color Project Overview
========================================================================

AppWizard has created this ALP LED API Sample Single-Color application for you.

This file contains a summary of what you will find in each of the files that
make up your ALP LED API Sample Single-Color application.


ALP LED API Sample Single-Color.vcxproj
    This is the main project file for VC++ projects generated using an Application Wizard.
    It contains information about the version of Visual C++ that generated the file, and
    information about the platforms, configurations, and project features selected with the
    Application Wizard.

ALP LED API Sample Single-Color.vcxproj.filters
    This is the filters file for VC++ projects generated using an Application Wizard. 
    It contains information about the association between the files in your project 
    and the filters. This association is used in the IDE to show grouping of files with
    similar extensions under a specific node (for e.g. ".cpp" files are associated with the
    "Source Files" filter).

ALP LED API Sample Single-Color.cpp
    This is the main application source file.

/////////////////////////////////////////////////////////////////////////////
Other standard files:

StdAfx.h, StdAfx.cpp
    These files are used to build a precompiled header (PCH) file
    named ALP LED API Sample Single-Color.pch and a precompiled types file named StdAfx.obj.

/////////////////////////////////////////////////////////////////////////////
Other notes:

AppWizard uses "TODO:" comments to indicate parts of the source code you
should add to or customize.

/////////////////////////////////////////////////////////////////////////////
