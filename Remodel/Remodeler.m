//
//  Remodeler.m
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Remodeler.h"
#import "ApplicationConstants.h"
#import "StringConstants.h"
#import "PreferenceListKeys.h"
#import "STPrivilegedTask.h"

#define kDefaultDictionaryCapacity			6

//#define kWindowParameterFocusedWindow		@"WindowParameterFocusedWindow"
#define kWindowParameterWindowPosition		@"WindowParameterWindowPostion"
#define kWindowParameterWindowSize			@"WindowParameterWindowSize"
#define kWindowParameterScreenPosition		@"WindowParameterScreenPosition"
#define kWindowParameterScreenSize			@"WindowParameterScreenSize" // this is not actually used
#define kWindowParameterVisibleScreenPosition	@"WindowParameterVisibleScreenPosition"
#define kWindowParameterVisibleScreenSize	@"WindowParameterVisibleScreenSize"


@implementation Remodeler

- (id)init
{
	if(self = [super init])
	{
		_systemWideElement = AXUIElementCreateSystemWide();
	}
	return self;
}

- (void)dealloc
{
	CFRelease(_systemWideElement);
	[super dealloc];
}

#pragma mark -
#pragma mark AXEnabled Methods

- (BOOL)isAccessibilityEnabled
{
	return (AXAPIEnabled() || AXIsProcessTrusted());
}

- (BOOL)setupAccessibility
{
	if (![self isAccessibilityEnabled])
	{
		NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
		
		if([standardUserDefaults boolForKey:kPLAccessibilityMakeTrusted])
		{
			NSString* strExePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kAppBinaryPath];
			
			// Must be root for this to succeed.
			AXError error = AXMakeProcessTrusted((CFStringRef)strExePath);
			if(error == kAXErrorSuccess)
			{
				NSLog(@"Remodel - Successfully registered process as trusted.");
				// Only try this once...
				[standardUserDefaults setBool:NO forKey:kPLAccessibilityMakeTrusted];
				[standardUserDefaults synchronize];
				
				// FIXME: Sometimes the register as trusted will not persist
				// On Success, launch new instance, and kill current instance
				//[NSTask launchedTaskWithLaunchPath:strExePath arguments:[NSArray array]];
			}
			else
			{
				NSLog(@"Remodel - Unable to register process as trusted. Launching privileged task to attempt to make process trusted.");
				
				// This will block until the process is killed
				// FIXME: pass in arguments to make it clear this is a privileged process... so we don't try to launch another instance
				[STPrivilegedTask launchedPrivilegedTaskWithLaunchPath:strExePath arguments:[NSArray array]];
				
				// Next process should not attempt this
				[standardUserDefaults setBool:NO forKey:kPLAccessibilityMakeTrusted];
				[standardUserDefaults synchronize];
				
				// Privileged process complete, launch new instance, and kill current instance
				// FIXME: This process can hang after two hot keys are used...
				[NSTask launchedTaskWithLaunchPath:strExePath arguments:[NSArray array]];
				//[NSApp terminate:self];
			}
			return NO;
		}
		// On Failure, give option to adjust AX settings
		[self displayAccessibilityAlertPanel];
	}
	return YES;
}

- (void)displayAccessibilityAlertPanel
{
	[NSApp activateIgnoringOtherApps:YES];
	
	int iRet = NSRunAlertPanel(STR_TITLE_ASSISTIVE_DEVICES, 
							   [NSString stringWithFormat:STR_BODY_ASSISTIVE_DEVICES, kAppName], 
							   STR_YES, 
							   [NSString stringWithFormat:STR_QUIT_APPLICATION, kAppName],
							   STR_CANCEL,
							   NULL);
	if(iRet == NSAlertDefaultReturn)
	{
		[[NSWorkspace sharedWorkspace] openFile:kSystemPreferencesUniversalAccess];
	}
	else if(iRet == NSAlertAlternateReturn)
	{
		[NSApp terminate:self];
	}
}

#pragma mark -
#pragma mark AXPositionWindow Methods

- (int)getMenuBarHeight
{
	// FIXME: MBarHeight is deprecated
	//[[NSApp mainMenu] menuBarHeight];
	//[[NSScreen mainScreen] visibleFrame];
	return GetMBarHeight();
}

- (BOOL)positionWindow:(CFTypeRef)focusedWindow withOrigin:(CFTypeRef)windowPosition
{
	if(AXUIElementSetAttributeValue((AXUIElementRef)focusedWindow,
									(CFStringRef)NSAccessibilityPositionAttribute,
									(CFTypeRef*)windowPosition) != kAXErrorSuccess)
	{
		NSLog(@"Remodel - Window position cannot be modified.");
		return NO;
	}
	return YES;
}

- (BOOL)positionWindow:(CFTypeRef)focusedWindow withOrigin:(CFTypeRef)windowPosition size:(CFTypeRef)windowSize
{
	if(![self positionWindow:focusedWindow withOrigin:windowPosition])
	{
		return NO;
	}
	
	if(AXUIElementSetAttributeValue((AXUIElementRef)focusedWindow,
									(CFStringRef)NSAccessibilitySizeAttribute,
									(CFTypeRef*)windowSize) != kAXErrorSuccess)
	{
		NSLog(@"Remodel - Window size cannot be modified.");
		return NO;
	}
	return YES;
}

-(BOOL)getFocusedScreenParameters:(NSMutableDictionary*)dictionary
{	
	// FIXME: find out the total number of displays, then create an array of that size and pass the values in
	// the window could span all displays and there could be n displays
	// all this code assumes 2 displays
    CGDirectDisplayID directDisplayIDs[2];
    CGDisplayCount displayCount;
	
	NSPoint windowPosition = [[dictionary valueForKey:kWindowParameterWindowPosition] pointValue];
	NSSize windowSize =[[dictionary valueForKey:kWindowParameterWindowSize] sizeValue];
	
    CGError error = CGGetDisplaysWithRect(CGRectMake(windowPosition.x, windowPosition.y, windowSize.width, windowSize.height), 2, directDisplayIDs, &displayCount);
    if(error == kCGErrorSuccess)
	{
		if(displayCount <= 0)
		{
			return NO;
		}
		
		// select first display by default
        CGRect chosenDisplayBounds = CGDisplayBounds(directDisplayIDs[0]);
		
        if (displayCount == 2) 
		{
			// FIXME: clean all this up
			CGRect displayBounds0 = chosenDisplayBounds;
            CGRect displayBounds1 = CGDisplayBounds(directDisplayIDs[1]);
			
            int delta = abs(displayBounds0.origin.x - (windowPosition.x+windowSize.width));
            int delta2 = 0;
			
            if(delta > displayBounds0.size.width)
			{
                delta = abs(windowPosition.x - (displayBounds0.origin.x+displayBounds0.size.width));
                delta2 = abs(windowPosition.x+windowSize.width - displayBounds1.origin.x);
            }
			else
			{
                delta2 = abs(windowPosition.x - (displayBounds1.origin.x+displayBounds1.size.width));
            }
			
            if (delta2 > delta)
			{
                chosenDisplayBounds = displayBounds1;
            }
        }
		
		[dictionary setValue:[NSValue valueWithPoint:chosenDisplayBounds.origin] forKey:kWindowParameterScreenPosition];
		[dictionary setValue:[NSValue valueWithSize:chosenDisplayBounds.size] forKey:kWindowParameterScreenSize];
		
		// FIXME: more stuff to clean up, do we need to store the above values anymore
		NSArray* screens = [NSScreen screens];
		for(NSScreen* screen in screens)
		{
			if (screen.frame.origin.x == chosenDisplayBounds.origin.x)
			{
				[dictionary setValue:[NSValue valueWithPoint:screen.visibleFrame.origin] forKey:kWindowParameterVisibleScreenPosition];
				[dictionary setValue:[NSValue valueWithSize:screen.visibleFrame.size] forKey:kWindowParameterVisibleScreenSize];
				break;
			}
		}
		return YES;
    }
	return NO;
}

- (BOOL)getFocusedWindowParameters:(CFTypeRef*)focusedWindow dictionary:(NSMutableDictionary*)dictionary
{
	AXUIElementRef focusedApp;
	
	//CFTypeRef* focusedWindow;
	CFTypeRef windowPosition;
	CFTypeRef windowSize;
	
	AXUIElementCopyAttributeValue(_systemWideElement, (CFStringRef)kAXFocusedApplicationAttribute, (CFTypeRef*)&focusedApp);
	
	if(AXUIElementCopyAttributeValue((AXUIElementRef)focusedApp, (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef*)focusedWindow) == kAXErrorSuccess)
	{
		// cannot store this in a dictionary, adding as argument
		//[dictionary setValue:focusedWindow forKey:kWindowParameterFocusedWindow];
		
		if(CFGetTypeID(*focusedWindow) == AXUIElementGetTypeID()) 
		{
			if(AXUIElementCopyAttributeValue((AXUIElementRef)*focusedWindow, (CFStringRef)NSAccessibilityPositionAttribute, (CFTypeRef*)&windowPosition) == kAXErrorSuccess) 
			{
                if(AXValueGetType(windowPosition) == kAXValueCGPointType)
				{
					NSPoint ptWindowPosition;
                    AXValueGetValue(windowPosition, kAXValueCGPointType, (void*)&ptWindowPosition);
					[dictionary setValue:[NSValue valueWithPoint:ptWindowPosition] forKey:kWindowParameterWindowPosition];
                }
				else
				{
					NSLog(@"Remodel - Window position not a point.");
					return NO;
                }                
            }
			else
			{
				NSLog(@"Remodel - Unable to retrieve window position.");
				return NO;
			}
			
			if(AXUIElementCopyAttributeValue((AXUIElementRef)*focusedWindow, (CFStringRef)NSAccessibilitySizeAttribute, (CFTypeRef*)&windowSize) == kAXErrorSuccess)
			{
                if(AXValueGetType(windowSize) == kAXValueCGSizeType)
				{
					NSSize sizeWindowSize;
                    AXValueGetValue(windowSize, kAXValueCGSizeType, (void*)&sizeWindowSize);
					[dictionary setValue:[NSValue valueWithSize:sizeWindowSize] forKey:kWindowParameterWindowSize];
                }
				else
				{
                    NSLog(@"Remodel - Window size was not a size.");
					return NO;
                }
            }
			else
			{
				NSLog(@"Remodel - Unable to retrieve window size.");
				return NO;
			}
		}
	}
	else
	{
		NSLog(@"Remodel - Unable to retrieve focused app.");
		return NO;
	}
	return YES;
}

-(BOOL)getWindowParameters:(CFTypeRef*)focusedWindow dictionary:(NSMutableDictionary*)dictionary
{
	if(![self isAccessibilityEnabled])
	{
		[self displayAccessibilityAlertPanel];
		return NO;
	}
	
	if(![self getFocusedWindowParameters:focusedWindow dictionary:dictionary])
	{
		return NO;
	}
	
	if(![self getFocusedScreenParameters:dictionary])
	{
		return NO;
	}
    return YES;
}

#pragma mark -
#pragma mark Shifting Methods

-(IBAction)shiftToLeftHalf:(id)sender
{
	CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
        
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
		
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ? 
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = ((szWindowSize.width)/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));
		
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Left Half");
    focusedWindow = NULL;
}

-(IBAction)shiftToRightHalf:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{      
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
		
		ptWindowPosition.x = ptWindowPosition.x +(szWindowSize.width/2);
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ? 
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = ((szWindowSize.width)/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Right Half");
    focusedWindow = NULL;
}

-(IBAction)shiftToTopHalf:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{     
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
		
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ? 
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Top Half");
    focusedWindow = NULL;
}

-(IBAction)shiftToBottomHalf:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		ptWindowPosition.y = (szWindowSize.height/2) + ((ptWindowPosition.x == 0) ?
														[self getMenuBarHeight] : 
														0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Bottom Half");
    focusedWindow = NULL;
}

-(IBAction)shiftToTopLeft:(id)sender
{
	CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ?
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = (szWindowSize.width/2);
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Top Left");
    focusedWindow = NULL;
}

-(IBAction)shiftToTopRight:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		ptWindowPosition.x = ptWindowPosition.x + (szWindowSize.width/2);
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ?
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = (szWindowSize.width/2);
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Top Right");
    focusedWindow = NULL;
}

-(IBAction)shiftToBottomLeft:(id)sender
{
	CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		ptWindowPosition.y = (szWindowSize.height/2) + ((ptWindowPosition.x == 0) ?
														[self getMenuBarHeight] :
														0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = (szWindowSize.width/2);
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Bottom Left");
    focusedWindow = NULL;
}

-(IBAction)shiftToBottomRight:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		// need to position this before the x coord
		ptWindowPosition.y = (szWindowSize.height/2) + ((ptWindowPosition.x == 0) ?
														[self getMenuBarHeight] :
														0);
		ptWindowPosition.x = ptWindowPosition.x + (szWindowSize.width/2);
		
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        szWindowSize.width = (szWindowSize.width/2);
        szWindowSize.height = (szWindowSize.height/2);
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Bottom Right");
    focusedWindow = NULL;
}

-(IBAction)shiftToCenter:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
        NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
		NSSize windowSize = [[dictionary valueForKey:kWindowParameterWindowSize] sizeValue];
		
		ptWindowPosition.x = ptWindowPosition.x + (szWindowSize.width/2) - (windowSize.width/2);
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ?
							  [self getMenuBarHeight] :
							  0) + (szWindowSize.height/2) - (windowSize.height/2);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
        
		[self positionWindow:focusedWindow withOrigin:windowPosition];
    }
    NSLog(@"Shifted To Center");
    focusedWindow = NULL;
}

-(IBAction)fullScreen:(id)sender
{
    CFTypeRef focusedWindow;
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:kDefaultDictionaryCapacity];
	
	if([self getWindowParameters:&focusedWindow dictionary:dictionary])
	{
        CFTypeRef windowPosition;
        CFTypeRef windowSize;
		
		NSPoint ptWindowPosition = [[dictionary valueForKey:kWindowParameterVisibleScreenPosition] pointValue];
		NSSize szWindowSize = [[dictionary valueForKey:kWindowParameterVisibleScreenSize] sizeValue];
        
		ptWindowPosition.y = ((ptWindowPosition.x == 0) ?
							  [self getMenuBarHeight] :
							  0);
		windowPosition = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&ptWindowPosition));
		
        windowSize = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&szWindowSize));					
        
		[self positionWindow:focusedWindow withOrigin:windowPosition size:windowSize];
    }
    NSLog(@"Shifted To Full Screen");
    focusedWindow = NULL;
}

#pragma mark -
#pragma mark Singleton Methods

static Remodeler* sharedRemodelerInstance = nil;

+ (Remodeler*)sharedInstance
{
    if (sharedRemodelerInstance == nil)
	{
        sharedRemodelerInstance = [[super allocWithZone:NULL] init];
    }
    return sharedRemodelerInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
