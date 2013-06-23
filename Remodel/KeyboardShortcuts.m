//
//  KeyboardShortcuts.m
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardShortcuts.h"
#import "PreferenceListKeys.h"
#import "WindowQuadrant.h"
#import "ObserverNotifications.h"

@implementation KeyboardShortcuts

- (id)init
{
	if(self = [super init])
	{
		_keyboardShortcutsOrder = [[NSMutableArray alloc] initWithCapacity:WQ_LAST];
		_iNextHotKeyID = WQ_LAST;
		
		[self _initializeKeyboardShortcutsOrder];
	}
	return self;
}

- (void)dealloc
{
	[_keyboardShortcutsOrder release];
	_keyboardShortcutsOrder = nil;
	[super dealloc];
}

- (void)_initializeKeyboardShortcutsOrder
{
	NSDictionary* allHotKeysDictionary = [self keyboardShortcuts];
	NSMutableArray* allHotKeyIDs = [NSMutableArray arrayWithArray:[allHotKeysDictionary allKeys]];
	
	// add all the defaults in the proper order
	for(int iHotKeyID = WQ_FIRST; iHotKeyID < WQ_LAST; iHotKeyID++)
	{
		[self _appendKeyboardShortcutToOrder:iHotKeyID];
		[allHotKeyIDs removeObject:[NSString stringWithFormat:@"%d", iHotKeyID]];
	}
	
	// add remaining keys
	for(int i = 0; i < [allHotKeyIDs count]; i++)
	{
		NSInteger iHotKeyID = [[allHotKeyIDs objectAtIndex:i] integerValue];
		[self _appendKeyboardShortcutToOrder:iHotKeyID];
		
		// keep the next key code ID as the highest number
		if(iHotKeyID >= _iNextHotKeyID)
		{
			_iNextHotKeyID = iHotKeyID+1;
		}
	}
}

- (void)_appendKeyboardShortcutToOrder:(NSInteger)identifier
{
	[_keyboardShortcutsOrder addObject:[NSNumber numberWithInteger:identifier]];
}

- (void)addKeyboardShortcut:(NSString*)strName keyCode:(NSInteger)iKeyCode modifiers:(NSNumber*)keyModifiers
{
	NSInteger iHotKeyID = _iNextHotKeyID++;
	
	// TODO: add to NSDefaults as enabled
	
	// TODO: append to end of array order
	[self _appendKeyboardShortcutToOrder:iHotKeyID];
	
	// TODO: send out update... to add to keyboard hooks
	// attach an NSNumber with the id?
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddKeyboardShortcut
														object:[NSNumber numberWithInteger:iHotKeyID]];
	/*
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationActivateHotKey
														object:[NSNumber numberWithInteger:iHotKeyID]];*/
}

- (void)removeKeyboardShortcut:(NSInteger)iHotKeyID
{
	
}

- (void)setHotKey:(NSInteger)iHotKeyID activated:(BOOL)bActivated
{
	// TODO: make change in NSDefaults, check to make sure nothing is different?
	NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* allHotKeysDictionary = [NSMutableDictionary dictionaryWithDictionary:[standardUserDefaults dictionaryForKey:kPLHotKeysDictionaryKey]];
	
	NSString* strHotKeyID = [NSString stringWithFormat:@"%d", iHotKeyID];
	NSMutableDictionary* hotKeyDictionary = [NSMutableDictionary dictionaryWithDictionary:[allHotKeysDictionary valueForKey:strHotKeyID]];
	if(hotKeyDictionary)
	{
		[hotKeyDictionary setValue:[NSNumber numberWithBool:bActivated] forKey:kPLHotKeyEnabledKey];
		[allHotKeysDictionary setValue:hotKeyDictionary forKey:strHotKeyID];
		
		[standardUserDefaults setObject:allHotKeysDictionary
								 forKey:kPLHotKeysDictionaryKey];
		[standardUserDefaults synchronize];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetHotKeyActivated
															object:[NSNumber numberWithInteger:iHotKeyID]
														  userInfo:hotKeyDictionary];
	}
}

#pragma mark -
#pragma mark Accessor Methods

- (NSDictionary*)keyboardShortcuts
{
	return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPLHotKeysDictionaryKey];
}

- (NSArray*)keyboardShortcutsOrder
{
	return _keyboardShortcutsOrder;
}

#pragma mark -
#pragma mark Singleton Methods

static KeyboardShortcuts* sharedKeyboardShortcutsManager = nil;

+ (KeyboardShortcuts*)sharedManager
{
    if (sharedKeyboardShortcutsManager == nil)
	{
        sharedKeyboardShortcutsManager = [[super allocWithZone:NULL] init];
    }
    return sharedKeyboardShortcutsManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
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
