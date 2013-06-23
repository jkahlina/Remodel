//
//  KeyboardHooks.m
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardHooks.h"
#import "HotKey.h"
#import "PreferenceListKeys.h"
#import "WindowQuadrant.h"
#import "ObserverNotifications.h"
#import "Remodeler.h"
#import "KeyboardShortcuts.h"

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID,
					  NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	
	[(KeyboardHooks*)userData handleHotKey:hotKeyID.id];
	
	// Allow other handlers to respond to the hot keys
	// \FIXME: Neither of these work, we could just return 'noErr'
	return eventNotHandledErr; //CallNextEventHandler(nextHandler, theEvent);
}

@implementation KeyboardHooks

- (id)init
{
	if(self = [super init])
	{
		_hotKeysDictionary = [[NSMutableDictionary alloc] initWithCapacity:WQ_LAST];
		
		[self installEventHandler];
		[self initializeHotKeys];
		
		[self registerForObserverNotifications];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterForObserverNotifications];
	[_hotKeysDictionary release];
	_hotKeysDictionary = nil;
	[super dealloc];
}

- (void)installEventHandler
{
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	InstallApplicationEventHandler(&MyHotKeyHandler, 1, &eventType, self, NULL);
}

- (void)initializeHotKeys
{
	NSDictionary* allHotKeysDictionary = [[KeyboardShortcuts sharedManager] keyboardShortcuts];
	NSArray* allHotKeyIDs = [allHotKeysDictionary allKeys];
	
	for(NSString* strHotKeyID in allHotKeyIDs)
	{
		[self _addHotKey:[strHotKeyID integerValue] fromDictionary:[allHotKeysDictionary valueForKey:strHotKeyID]];
	}
}

- (void)_addHotKey:(NSInteger)iHotKeyID fromDictionary:(NSDictionary*)hotKeyDictionary
{
	if(hotKeyDictionary)
	{
		BOOL bKeyEnabled = [[hotKeyDictionary valueForKey:kPLHotKeyEnabledKey] boolValue];
		if(bKeyEnabled)
		{
			NSNumber* numberKeyCode = [hotKeyDictionary valueForKey:kPLHotKeyCodeKey];
			NSNumber* numberModifiers = [hotKeyDictionary valueForKey:kPLHotKeyModifiersKey];
			
			// Add the keycode for each id
			HotKey* hotKey = [[HotKey alloc] initWithIdentifier:iHotKeyID
														keyCode:[numberKeyCode integerValue] 
													  modifiers:numberModifiers];
			[_hotKeysDictionary setObject:hotKey forKey:[NSNumber numberWithInteger:hotKey.hotKeyID]];
			[hotKey release];
		}
	}
}

- (void)handleHotKey:(int)iHotKeyID
{
	// FIXME: this should look for some position in the data layer that this ID corresponds to
	
	Remodeler* remodeler = [Remodeler sharedInstance];
	
	switch (iHotKeyID)
	{
		case WQ_1:
			[remodeler shiftToTopRight:self];
			break;
		case WQ_12:
			[remodeler shiftToTopHalf:self];
			break;
		case WQ_2:
			[remodeler shiftToTopLeft:self];
			break;
		case WQ_23:
			[remodeler shiftToLeftHalf:self];
			break;
		case WQ_3:
			[remodeler shiftToBottomLeft:self];
			break;
		case WQ_34:
			[remodeler shiftToBottomHalf:self];
			break;
		case WQ_4:
			[remodeler shiftToBottomRight:self];
			break;
		case WQ_14:
			[remodeler shiftToRightHalf:self];
			break;
		case WQ_0:
			[remodeler shiftToCenter:self];
			break;
		case WQ_1234:
			[remodeler fullScreen:self];
			break;
		default:
			NSLog(@"Remodel - Unknown hot key ID %d.", iHotKeyID);
			break;
	}
}

#pragma mark -
#pragma mark ObserverNotification Methods

- (void)registerForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(onSetHotKeyActivated:) 
												 name:kNotificationSetHotKeyActivated 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(onTriggerHotKey:) 
												 name:kNotificationTriggerHotKey 
											   object:nil];
}

- (void)unregisterForObserverNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onTriggerHotKey:(NSNotification *)notification
{
	NSNumber* numberHotKeyID = [notification object];
	[self handleHotKey:[numberHotKeyID integerValue]];
}

- (void)onSetHotKeyActivated:(NSNotification *)notification
{
	NSNumber* numberHotKeyID = [notification object];
	BOOL bActivated = [[[notification userInfo] valueForKey:kPLHotKeyEnabledKey] boolValue];
	
	if(bActivated)
	{
		[self _addHotKey:[numberHotKeyID integerValue]
		  fromDictionary:[notification userInfo]];
	}
	else
	{
		[_hotKeysDictionary removeObjectForKey:numberHotKeyID];
	}
}

@end
