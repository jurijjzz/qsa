/*
	This sample is provided as-is, without any warranty.

	Please always consult the ALP basic API description when
	customizing this program. It contains a detailled specification
	of all Alpb... functions.

	© 2008-2013 ViALUX GmbH. All rights reserved.
*/

// CPP ConsoleSample ALP basic.cpp
//

#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <alpbasic.h>

unsigned char *SampleImages( unsigned long nSizeX, unsigned long nSizeY );
int CleanUp( ALPB_HDEVICE *alpid, void *image, char *msg = NULL, long nResult = -1 );

int main(int /*argc*/, char ** /*argv*/)
{
	long ret;
	ALPB_HDEVICE alpid;
	unsigned long serial;
	unsigned char *image;
	signed long i;

	ALPB_DMDTYPES nDmdType;
	long nSizeX, nSizeY;

	printf( "CPP ConsoleSample ALP basic.exe\n" );
	
	// The first thing to do is to allocate one ALP device.
	// The alpid serves for further requests to identify the device.
	ret = AlpbDevAlloc( 0, &alpid );
	if (0>ret) return CleanUp( NULL, NULL, "Error: AlpbDevAlloc\n", ret );

	// Query serial number
	ret = AlpbDevInquire( alpid, ALPB_DEV_SERIAL, &serial );
	if (0>ret) return CleanUp( NULL, NULL, "Error: AlpbDevInquire (Serial number)\n", ret );
	printf( "The allocated ALP has the serial number %i\n", serial );

	// Detect DMD type
	ret = AlpbDevInquire( alpid, ALPB_DEV_DMDTYPE, &nDmdType );
	if (0>ret) return CleanUp( NULL, NULL, "Error: AlpbDevInquire (DMD type)\n", ret );

	// Evaluate DMD type
	// Applications often depend on a particular DMD type. In this case just
	// inquire ALPB_DEV_DMDTYPE and reject all unsupported types.
	switch (nDmdType) {
	case ALPB_DMDTYPE_DISCONNECT :
		printf( "DMD type: DMD disconnected or not recognized\nEmulate 1080p\n" );
		nSizeX = 1920; nSizeY = 1080;
		break;
	case ALPB_DMDTYPE_1080P_095A :
		printf( "DMD type: 1080p .95\" Type-A\n" );
		nSizeX = 1920; nSizeY = 1080;
		break;
	case ALPB_DMDTYPE_WUXGA_096A :
		printf( "DMD type: WUXGA .96\" Type-A\n" );
		nSizeX = 1920; nSizeY = 1200;
		break;

	case ALPB_DMDTYPE_XGA :
		printf( "DMD type: XGA\n" );
		nSizeX = 1024; nSizeY = 768;
		break;
	case ALPB_DMDTYPE_XGA_055A :
		printf( "DMD type: XGA .55\" Type-A\n" );
		nSizeX = 1024; nSizeY = 768;
		break;
	case ALPB_DMDTYPE_XGA_055X :
		printf( "DMD type: XGA .55\" Type-X\n" );
		nSizeX = 1024; nSizeY = 768;
		break;
	case ALPB_DMDTYPE_XGA_07A :
		printf( "DMD type: XGA .7\" Type-A\n" );
		nSizeX = 1024; nSizeY = 768;
		break;

	default :
		return CleanUp( NULL, NULL,
			"DMD type: (unknown)\n"
			"Error: DMD type not known\n",
			-1);
	}

	// Only binary images are projected in the basic version of ALP.
	// They are directly loaded from PC via USB to the DMD memory

	// Now, images are generated in the PCs memory.
	image = SampleImages(nSizeX, nSizeY);
	if (NULL == image) return CleanUp( &alpid, NULL, "Error: SampleImages\n" );

// Demonstration using full DMD: Start alternating projection of images.
	printf( "Alternate display of 3 images: " );
	for (i=0; i<10; i++) {
		// Load the first image to the DMD
		ret = AlpbDevLoadRows( alpid, image, 0, nSizeY-1 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (1)\n", ret );
		// Reset DMD mirrors
		ret = AlpbDevReset( alpid, ALPB_RESET_GLOBAL, 0 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevReset (1)\n", ret );
		printf( "." );
		Sleep( 200 );	// milliseconds

		// Load the second image to the DMD
		ret = AlpbDevLoadRows( alpid, &image[nSizeX*nSizeY], 0, nSizeY-1 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (2)\n", ret );
		// Reset DMD mirrors
		ret = AlpbDevReset( alpid, ALPB_RESET_GLOBAL, 0 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevReset (2)\n", ret );
		printf( "o" );
		Sleep( 200 );	// milliseconds

		// Load the third image to the DMD
		ret = AlpbDevLoadRows( alpid, &image[2*nSizeX*nSizeY], 0, nSizeY-1 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (3)\n", ret );
		// Reset DMD mirrors
		ret = AlpbDevReset( alpid, ALPB_RESET_GLOBAL, 0 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevReset (3)\n", ret );
		printf( "O" );
		Sleep( 200 );	// milliseconds
	}
	printf( "\n" );


// Demonstration of partial DMD loading:
// Sub-Divide the DMD into 3 horizontal bars containing data from image1, image2, and image3
	printf( "Combine them:\n" );
	// Load the first image to the DMD, top bar
	ret = AlpbDevLoadRows( alpid, image, 0, nSizeY/3-1 );
	if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (4)\n", ret );
	// Load the second image to the DMD
	ret = AlpbDevLoadRows( alpid, &image[nSizeX*nSizeY], nSizeY/3, 2*nSizeY/3-1 );
	if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (5)\n", ret );
	// Load the third image to the DMD
	ret = AlpbDevLoadRows( alpid, &image[2*nSizeX*nSizeY], 2*nSizeY/3, nSizeY-1 );
	if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevLoadRows (6)\n", ret );
	// Reset DMD mirrors
	ret = AlpbDevReset( alpid, ALPB_RESET_GLOBAL, 0 );
	if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevReset (4)\n", ret );
	Sleep( 500 );

	// Clear the DMD area bottom-up; reset
	printf( "Clear DMD bottom-up: " );
	for (i=15; i>=0; i--) {
		ret = AlpbDevClear(alpid, i, i );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevClear\n", ret );
		ret = AlpbDevReset( alpid, ALPB_RESET_GLOBAL, 0 );
		if (0>ret) return CleanUp( &alpid, image, "Error: AlpbDevReset (5)\n", ret );
		printf( "." );
		Sleep( 100 );
	}
	printf( "\n" );

	Sleep( 1000 );	// milliseconds

	printf( "Clean up, release ALP device\n" );
	CleanUp( &alpid, image, "Properly finished\n" );

	return 0;
}


unsigned char *SampleImages( unsigned long nSizeX, unsigned long nSizeY )
{
	unsigned long x, y;
	unsigned char *image;

	image = (unsigned char*) malloc( nSizeX*nSizeY*3 );
	if (NULL != image) {
		// Picture 0: horizontal bars
		for (y=0; y<nSizeY; y++)
			FillMemory(
				image + 0*nSizeY*nSizeX + y*nSizeX,	// row start address
				nSizeX,	// row size in bytes
				(y&32)? 0 : 128 );	// image data: either 0 or 128

		// Picture 1:  checkered pattern
		for (y=0; y<nSizeY; y++)
			for (x=0; x<nSizeX; x++)
				image[1*nSizeY*nSizeX + y*nSizeX + x] =	
					(unsigned char) ((x^y)& 32)? 0 : 128;

		// Picture 2:  vertical bars
		for (y=0; y<nSizeY; y++)
			for (x=0; x<nSizeX; x++)
				image[2*nSizeY*nSizeX + y*nSizeX + x] =	
					(unsigned char) (x&32)? 0 : 128;
	}

	return image;
}

int CleanUp( ALPB_HDEVICE *alpid, void *image, char *msg, long nResult )
{
	if (NULL != alpid) {
		long bHalt = 1;
		AlpbDevControl( *alpid, ALPB_DEV_HALT, &bHalt );	// actually only necessary in multithreading use
		AlpbDevFree( *alpid );	// close device driver
	}

	if (NULL != image)
		free( image );

	if (-1 != nResult) {
		char strMsg[100];
		long nSize = sizeof(strMsg);
		if (0>AlpbDllGetResultText( nResult, &nSize, strMsg ))
			printf( "ALP basic API error code 0x%08x, see alpbasic.h\n", nResult );
		else
			printf( "ALP basic API error (code 0x%08x, see alpbasic.h):\n %s\n", nResult, strMsg );
	}

	if (NULL != msg)
		printf( msg );

	printf( "Finishing Application, press any key\n" );
	_getch();

	return 1;
}
