//
//  Remodeler.h
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Remodeler : NSObject 
{
	AXUIElementRef	_systemWideElement;
}

+ (Remodeler*)sharedInstance;

- (BOOL)isAccessibilityEnabled;
- (BOOL)setupAccessibility;
- (void)displayAccessibilityAlertPanel;

- (BOOL)positionWindow:(CFTypeRef)focusedWindow withOrigin:(CFTypeRef)windowPosition;
- (BOOL)positionWindow:(CFTypeRef)focusedWindow withOrigin:(CFTypeRef)windowPosition size:(CFTypeRef)windowSize;

-(IBAction)shiftToLeftHalf:(id)sender;
-(IBAction)shiftToRightHalf:(id)sender;
-(IBAction)shiftToBottomHalf:(id)sender;
-(IBAction)shiftToTopHalf:(id)sender;
-(IBAction)shiftToTopRight:(id)sender;
-(IBAction)shiftToTopLeft:(id)sender;
-(IBAction)shiftToBottomLeft:(id)sender;
-(IBAction)shiftToBottomRight:(id)sender;
-(IBAction)fullScreen:(id)sender;
-(IBAction)shiftToCenter:(id)sender;

@end
