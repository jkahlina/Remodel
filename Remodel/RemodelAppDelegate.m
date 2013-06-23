//
//  RemodelAppDelegate.m
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RemodelAppDelegate.h"
#import "PreferenceListKeys.h"
#import "Remodeler.h"
#import "BDLaunchServicesHelper.h"

@implementation RemodelAppDelegate

#pragma mark NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// accessibility must be enabled for the application to work
	if([[Remodeler sharedInstance] setupAccessibility])
	{
		[_menuController setupStatusBarItem];
		[self startStopKeyboardHooks:YES];
		[self setupLaunchAtStartupIfNecessary];
	}
	else
	{
		[NSApp terminate:self];
	}
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// app could terminate before these things are setup
	[self startStopKeyboardHooks:NO];
	
	// dealloc is not hit in the delegate
	[_menuController release];
	_menuController = nil;
}

#pragma mark -
#pragma mark RemodelApp Methods

- (id)init
{
	if(self = [super init])
	{
		
	}
	return self;
}

- (void)dealloc
{
	// this is dealloc'd in willTerminate
	//[_menuController release];
	//_menuController = nil;
	[super dealloc];
}

- (void)startStopKeyboardHooks:(BOOL)bStart
{
	if(_keyboardHooks != nil)
	{
		[_keyboardHooks release];
		_keyboardHooks = nil;
	}
	
	if(bStart)
	{
		_keyboardHooks = [[KeyboardHooks alloc] init];
	}
}

- (void)setupLaunchAtStartupIfNecessary
{
	BOOL bShouldLaunchAtStartup = [[NSUserDefaults standardUserDefaults] boolForKey:kPLLaunchAtStartup];
	BOOL bIsLaunchAtStartup = [BDLaunchServicesHelper isLaunchAtStartup];
	
	if((bShouldLaunchAtStartup &&
	   !bIsLaunchAtStartup)
	   ||
	   (!bShouldLaunchAtStartup &&
		bIsLaunchAtStartup))
	{
		[BDLaunchServicesHelper toggleLaunchAtStartup];
	}
}

#pragma mark -
#pragma mark NSUserDefaults Initialization

// Initialize the default preferences of the app
+ (void)initialize
{
	[RemodelAppDelegate setupDefaults];
}

+ (void)setupDefaults
{
	// load the default values for the user defaults
	NSString* appDefaultsPListPath = [[NSBundle mainBundle] pathForResource:kPLAppDefaultsPList
																	 ofType:@"plist"];
	NSDictionary* appDefaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:appDefaultsPListPath];
	
	
	// set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaultsDictionary];
	
    // if your application supports resetting a subset of the defaults to
    // factory values, you should set those values
    // in the shared user defaults controller
	// FIXME: This is wrong... we want to initalize each of the hot keys independently?
	/*
    NSMutableArray* resetAppDefaultsKeys = [NSMutableArray arrayWithCapacity:WQ_LAST];
	for(int i = WQ_FIRST; i < WQ_LAST; i++)
	{
		[resetAppDefaultsKeys addObject:[NSString stringWithFormat:@"%d", i]];
	}
	
    NSDictionary* initialValuesDictionary = [appDefaultsDictionary dictionaryWithValuesForKeys:resetAppDefaultsKeys];
	*/
	// TODO: Only hot key defaults can be reset?
	//NSArray* resetAppDefaultsKeys = [NSArray arrayWithObject:kPLHotKeysDictionaryKey];
	//NSDictionary* initialValuesDictionary = [appDefaultsDictionary dictionaryWithValuesForKeys:resetAppDefaultsKeys];
	
    // Set the initial values in the shared user defaults controller
    //[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDictionary];
}

@end
