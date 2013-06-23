//
//  HotKey.m
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HotKey.h"
#import "ApplicationConstants.h"


@implementation HotKey
@synthesize keyCode = _keyCode;
@synthesize modifiers = _modifiers;
@synthesize hotKeyID = _hotKeyID;

- (id)initWithIdentifier:(NSInteger)identifier keyCode:(NSInteger)iKeyCode modifiers:(NSNumber*)keyModifiers
{
	if(self = [super init])
	{
		_hotKeyID = identifier;
		_keyCode = iKeyCode;
		_modifiers = [keyModifiers retain];
		[self registerHotKey];
	}
	return self;
}

- (void)dealloc
{
	[_modifiers release];
	_modifiers = nil;
	[self unregisterHotKey];
	[super dealloc];
}

- (BOOL)registerHotKey
{
	if(_eventHotKeyRef == nil)
	{
		OSStatus error;
		EventHotKeyID eventHotKeyID;
		
		eventHotKeyID.signature = kAppHotKeySignature;
		eventHotKeyID.id = self.hotKeyID;
		
		error = RegisterEventHotKey(self.keyCode, [self.modifiers unsignedIntValue], eventHotKeyID, GetApplicationEventTarget(), 0, &_eventHotKeyRef);
		if(error)
		{
			NSLog(@"Remodel - Unable to register hot key %d.", self.hotKeyID);
			return NO;
		}
	}
	return YES;
}

- (BOOL)unregisterHotKey
{
	if(_eventHotKeyRef != nil)
	{
		OSStatus error;
		error = UnregisterEventHotKey(_eventHotKeyRef);
		if(error)
		{
			NSLog(@"Remodel - Unable to unregister hot key %d.", self.hotKeyID);
			return NO;
		}
		_eventHotKeyRef = nil;
	}
	return YES;
}

@end
