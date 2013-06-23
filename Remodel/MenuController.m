//
//  MenuController.m
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "ApplicationConstants.h"
#import "PreferenceListKeys.h"
#import "ObserverNotifications.h"
#import "Remodeler.h"
#import "KeyboardShortcuts.h"
#import "SRCommon.h"

#define kKeyboardShortcutsSeparatorTag	-1
#define kKeyboardShortcutsSeparator		@"KeyboardShortcutsSeparator"
//#define kKeyboardShortcutsFirst			@"KeyboardShortcutsFirst"
//#define kKeyboardShortcutsLast			@"KeyboardShortcutsLast"

@implementation MenuController

- (id)init
{
	if(self = [super init])
	{
		_preferencesWindowController = [[PreferencesWindowController alloc] init];
		[self registerForObserverNotifications];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterForObserverNotifications];
	
	//[_positionWindowMenu release];
	//_positionWindowMenu = nil;
	
	[_statusMenu release];
	_statusMenu = nil;
	
	[[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
	[_statusItem release]; // FIXME: crashes?
	_statusItem = nil;
	
	[_positionWindowMenu release];
	_positionWindowMenu = nil;
	
	[_preferencesWindowController release];
	_preferencesWindowController = nil;
	[super dealloc];
}

- (void)setupStatusBarItem
{
	if(_statusItem == nil)
	{
		[self addHotKeyItemsToStatusMenu];
		
		// Setup the status bar item
		_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		[_statusItem setMenu:_statusMenu];
		//[_statusItem setTitle:kAppName];
		[_statusItem setImage:[NSImage imageNamed:kAppStatusBarIcon]];
		[_statusItem setAlternateImage:[NSImage imageNamed:kAppStatusBarIconHighlighted]];
		[_statusItem setHighlightMode:YES];
	}
}

- (void)addHotKeyItemsToStatusMenu
{
	NSMutableArray* arrayMenuItemOrder = [NSMutableArray arrayWithArray:[[KeyboardShortcuts sharedManager] keyboardShortcutsOrder]];
	
	// TODO: add in separators... in a better way
	const int iNumberOfSeparators = 2;
	const int iPartitionSize = 4;
	NSNumber* numSeparator = [NSNumber numberWithInt:kKeyboardShortcutsSeparatorTag];
	if([arrayMenuItemOrder count] > iNumberOfSeparators*iPartitionSize)
	{
		for(int i = iNumberOfSeparators; i > 0; i--)
		{
			[arrayMenuItemOrder insertObject:numSeparator
									 atIndex:i*iPartitionSize];
		}
	}
	//[arrayMenuItemOrder addObject:numSeparator];
	
	NSDictionary* allHotKeysDictionary = [[KeyboardShortcuts sharedManager] keyboardShortcuts];
	int iStartIndex = 0;//[_statusMenu indexOfItemWithTitle:kKeyboardShortcutsLast];
	
	for(int i = 0; i < [arrayMenuItemOrder count]; i++)
	{
		int iHotKeyID = [[arrayMenuItemOrder objectAtIndex:i] intValue];
		
		if(iHotKeyID == kKeyboardShortcutsSeparatorTag)
		{
			NSMenuItem* menuItem = [NSMenuItem separatorItem];
			[menuItem setTitle:kKeyboardShortcutsSeparator];
			[menuItem setTag:kKeyboardShortcutsSeparatorTag];
			[_positionWindowMenu insertItem:menuItem atIndex:iStartIndex++];
			continue;
		}
		
		NSDictionary* hotKeyDictionary = [allHotKeysDictionary valueForKey:[NSString stringWithFormat:@"%d", iHotKeyID]];
		if(hotKeyDictionary)
		{
			NSInteger iKeyCode = [[hotKeyDictionary valueForKey:kPLHotKeyCodeKey] integerValue];
			NSNumber* numberModifiers = [hotKeyDictionary valueForKey:kPLHotKeyModifiersKey];
			NSString* strKeyString = [hotKeyDictionary valueForKey:kPLHotKeyStringKey];
			BOOL bKeyEnabled = [[hotKeyDictionary valueForKey:kPLHotKeyEnabledKey] boolValue];
			
			NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:strKeyString 
															  action:@selector(positionWindow:) 
													   keyEquivalent:SRStringForKeyCode(iKeyCode)];
			
			[menuItem setTarget:self];
			[menuItem setKeyEquivalentModifierMask:(SRCarbonToCocoaFlags([numberModifiers unsignedIntValue]))];
			[menuItem setTag:iHotKeyID]; // note: tags default to zero
			[menuItem setEnabled:bKeyEnabled];
			[menuItem setToolTip:SRReadableStringForCarbonModifierFlagsAndKeyCode([numberModifiers unsignedIntValue], iKeyCode)];
			[_positionWindowMenu insertItem:menuItem atIndex:iStartIndex++];
			[menuItem release];
		}
	}
}

#pragma mark -
#pragma mark Menu Action Methods

- (IBAction)showAboutWindow:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)showPreferencesWindow:(id)sender
{
    [_preferencesWindowController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)positionWindow:(id)sender
{
	if(![sender isKindOfClass:[NSMenuItem class]])
	{
		return;
	}
	
	NSMenuItem* menuItem = (NSMenuItem*)sender;
	NSInteger iHotKeyID = [menuItem tag];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTriggerHotKey
														object:[NSNumber numberWithInteger:iHotKeyID]];
}

#pragma mark -
#pragma mark ObserverNotification Methods

- (void)registerForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(onSetHotKeyActivated:) 
												 name:kNotificationSetHotKeyActivated 
											   object:nil];
}

- (void)unregisterForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onSetHotKeyActivated:(NSNotification *)notification
{
	NSInteger iHotKeyID = [[notification object] integerValue];
	BOOL bActivated = [[[notification userInfo] valueForKey:kPLHotKeyEnabledKey] boolValue];
	
	NSMenuItem* menuItem = [_positionWindowMenu itemWithTag:iHotKeyID];
	[menuItem setEnabled:bActivated];
}

@end
