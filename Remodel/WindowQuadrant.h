/*
 *  WindowQuadrant.h
 *  Remodel
 *
 *  Created by Jeff Kahlina on 11-12-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

enum WINDOW_QUADRANT
{
	// The default key bindings for these quadrants are loaded into
	// the application from the AppDefaults.plist file.
	// This is also the default order of keyboard shortcuts.
	
	WQ_FIRST = 0,	// start of loop
	
	WQ_12 = 0,	// top
	WQ_34,		// bottom
	WQ_23,		// left
	WQ_14,		// right
	
	WQ_2,		// top-left
	WQ_1,		// top-right
	WQ_3,		// bottom-left
	WQ_4,		// bottom-right
	
	WQ_0,		// center
	WQ_1234,	// maximize
	
	WQ_LAST			// end of loop
};
