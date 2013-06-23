//
//  KeyboardHooks.h
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface KeyboardHooks : NSObject
{
	NSMutableDictionary* _hotKeysDictionary;
}

- (void)installEventHandler;
- (void)initializeHotKeys;
- (void)_addHotKey:(NSInteger)iHotKeyID fromDictionary:(NSDictionary*)hotKeyDictionary;
- (void)handleHotKey:(int)iHotKeyID;

- (void)registerForObserverNotifications;
- (void)unregisterForObserverNotifications;

- (void)onTriggerHotKey:(NSNotification *)notification;
- (void)onSetHotKeyActivated:(NSNotification *)notification;

@end
