//
//  PreferencesWindowController.m
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "PreferenceListKeys.h"
#import "ObserverNotifications.h"
#import "BDLaunchServicesHelper.h"
#import "KeyboardShortcuts.h"
#import "SRCommon.h"

#define kPWCHotKeyEnabledColumn		@"HotKeyEnabledColumn"
#define kPWCHotKeyStringColumn		@"HotKeyStringColumn"
#define kPWCHotKeyEquivalentColumn	@"HotKeyEquivalentColumn"

@implementation PreferencesWindowController

- (id)init
{
	if(self = [super initWithWindowNibName:@"PreferencesWindow"])
	{
		
	}
	return self;
}

- (void)dealloc
{
	[self unregisterForObserverNotifications];
	[[self window] close];
	
	[_tabView release];
	_tabView = nil;
	[_btnAccessibilityMakeTrusted release];
	_btnAccessibilityMakeTrusted = nil;
	[_btnLaunchAtStartup release];
	_btnLaunchAtStartup = nil;
	[_tableKeyboardShortcuts release];
	_tableKeyboardShortcuts = nil;
	[_dataSource release];
	_dataSource = nil;
	[super dealloc];
}

- (void)showWindow:(id)sender
{
	[[self window] center];
	[super showWindow:sender];
}

- (void)awakeFromNib
{
	[self setupKeyboardShortcutTable];
	[self initializePreferenceValues];
	
	[self registerForObserverNotifications];
}

- (void)setupKeyboardShortcutTable
{
	// Table is setup with the data source in the nib file.
	
	
	//[_tableKeyboardShortcuts setRowHeight:TABLE_ROW_HEIGHT];
	//[_tableKeyboardShortcuts setHeaderView: nil];
	//[_tableKeyboardShortcuts setSelectionHighlightStyle: NSTableViewSelectionHighlightStyleRegular];
	//[_tableKeyboardShortcuts setDelegate:self];
	
	// \TODO: modify columns if necessary
	
}

- (void)initializePreferenceValues
{
	NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[_btnAccessibilityMakeTrusted setState:([standardUserDefaults boolForKey:kPLAccessibilityMakeTrusted] ?
											NSOnState :
											NSOffState)];
	[_btnLaunchAtStartup setState:([standardUserDefaults boolForKey:kPLLaunchAtStartup] ?
											NSOnState :
											NSOffState)];
	[self initializeKeyboardShortcutTable];
}

- (void)initializeKeyboardShortcutTable
{
	NSArray* arrayKeyboardShortcuts = [[KeyboardShortcuts sharedManager] keyboardShortcutsOrder];
	NSDictionary* allHotKeysDictionary = [[KeyboardShortcuts sharedManager] keyboardShortcuts];
	
	for(int i = 0; i < [arrayKeyboardShortcuts count]; i++)
	{
		NSNumber* numberHotKeyID = [arrayKeyboardShortcuts objectAtIndex:i];
		
		NSDictionary* hotKeyDictionary = [allHotKeysDictionary valueForKey:[numberHotKeyID stringValue]];
		if(hotKeyDictionary)
		{
			NSInteger iKeyCode = [[hotKeyDictionary valueForKey:kPLHotKeyCodeKey] integerValue];
			NSNumber* numberModifiers = [hotKeyDictionary valueForKey:kPLHotKeyModifiersKey];
			NSString* strKeyString = [hotKeyDictionary valueForKey:kPLHotKeyStringKey];
			BOOL bKeyEnabled = [[hotKeyDictionary valueForKey:kPLHotKeyEnabledKey] boolValue];
			
			// FIXME: what is the proper way to create identical cells as the dataCell
			NSButtonCell* buttonCell = [[[_tableKeyboardShortcuts tableColumnWithIdentifier:kPWCHotKeyEnabledColumn] dataCell] copy];
			//[[NSButtonCell alloc] init];
			//[buttonCell setButtonType:NSSwitchButton];
			//[buttonCell setImagePosition:NSImageOnly];
			//[buttonCell setAlignment:NSCenterTextAlignment];
			[buttonCell setState:(bKeyEnabled ? NSOnState : NSOffState)];
			[buttonCell setTag:[numberHotKeyID integerValue]];
			// These are set in the nib by NSTableColumn...
			//[buttonCell setTarget:self];
			//[buttonCell setAction:@selector(onBtnKeyboardShortcutTableCell:)];
			
			[_dataSource addObject:buttonCell withIdentifier:kPWCHotKeyEnabledColumn row:i];
			[buttonCell release];
			
			NSTextFieldCell* stringCell = [[NSTextFieldCell alloc] initTextCell:strKeyString];
			[stringCell setAlignment:NSLeftTextAlignment];
			[stringCell setEditable:NO]; // TODO: customizable keyboard shortcut strings (set in nib)
			[_dataSource addObject:stringCell withIdentifier:kPWCHotKeyStringColumn row:i];
			[stringCell release];
			
			NSString* strKeyEquivalent = SRStringForCarbonModifierFlagsAndKeyCode([numberModifiers unsignedIntValue], iKeyCode);
			NSTextFieldCell* keyCell = [[NSTextFieldCell alloc] initTextCell:strKeyEquivalent];
			[keyCell setAlignment:NSRightTextAlignment];
			[keyCell setEditable:NO]; // TODO: customizable keyboard shortcuts (set in nib)
			[_dataSource addObject:keyCell withIdentifier:kPWCHotKeyEquivalentColumn row:i];
			[keyCell release];
		}
	}
	
	[_tableKeyboardShortcuts reloadData];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)onBtnAccessibilityMakeTrusted:(id)sender
{
	NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardUserDefaults setBool:([_btnAccessibilityMakeTrusted state] == NSOnState)
						   forKey:kPLAccessibilityMakeTrusted];
	[standardUserDefaults synchronize];
}

- (IBAction)onBtnLaunchAtStartup:(id)sender
{
	NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardUserDefaults setBool:([_btnLaunchAtStartup state] == NSOnState)
						   forKey:kPLLaunchAtStartup];
	[standardUserDefaults synchronize];
	
	[BDLaunchServicesHelper toggleLaunchAtStartup];
}

- (void)onBtnKeyboardShortcutTableCell:(id)sender
{
	if(![sender isKindOfClass:[NSTableView class]])
	{
		return;
	}
	
	NSTableView* tableView = (NSTableView*)sender;
	NSButtonCell* cell = [_dataSource objectWithIdentifier:kPWCHotKeyEnabledColumn row:[tableView selectedRow]];
	
	// Toggle the hot key activated state
	[[KeyboardShortcuts sharedManager] setHotKey:[cell tag] activated:([cell state] != NSOnState)];
}

#pragma mark -
#pragma mark ObserverNotification Methods

- (void)registerForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(onAddKeyboardShortcut:) 
												 name:kNotificationAddKeyboardShortcut 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(onSetHotKeyActivated:) 
												 name:kNotificationSetHotKeyActivated 
											   object:nil];
}

- (void)unregisterForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAddKeyboardShortcut:(NSNotification *)notification
{
	NSNumber* numberHotKeyID = [notification object];
	NSDictionary* hotKeyDictionary = [[[KeyboardShortcuts sharedManager] keyboardShortcuts] valueForKey:[numberHotKeyID stringValue]];
	if(hotKeyDictionary)
	{
		BOOL bKeyEnabled = [[hotKeyDictionary valueForKey:kPLHotKeyEnabledKey] boolValue];
		if(bKeyEnabled)
		{
			//NSNumber* numberKeyCode = [hotKeyDictionary valueForKey:kPLHotKeyCodeKey];
			//NSNumber* numberModifiers = [hotKeyDictionary valueForKey:kPLHotKeyModifiersKey];
			/*
			// add the keycode for each id
			HotKey* hotKey = [[HotKey alloc] initWithIdentifier:[strKeyCodeID intValue] 
														keyCode:[numberKeyCode intValue] 
													  modifiers:numberModifiers];
			[_hotKeysDictionary setObject:hotKey forKey:[NSNumber numberWithInt:hotKey.hotKeyID]];
			[hotKey release];*/
		}
	}
}

- (void)onSetHotKeyActivated:(NSNotification *)notification
{
	NSInteger iHotKeyID = [[notification object] integerValue];
	
	for(int i = 0; i < [_dataSource numberOfRowsInTableView:_tableKeyboardShortcuts]; i++)
	{
		NSButtonCell* cell = [_dataSource objectWithIdentifier:kPWCHotKeyEnabledColumn row:i];
		if([cell tag] == iHotKeyID)
		{
			BOOL bActivated = [[[notification userInfo] valueForKey:kPLHotKeyEnabledKey] boolValue];
			[cell setState:(bActivated ? NSOnState : NSOffState)];
			break;
		}
	}
}

@end
