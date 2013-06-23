//
//  HotKey.h
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface HotKey : NSObject
{
	NSInteger _keyCode;
	NSNumber* _modifiers;
	NSInteger _hotKeyID;
	
	EventHotKeyRef _eventHotKeyRef;
}

- (id)initWithIdentifier:(NSInteger)identifier keyCode:(NSInteger)iKeyCode modifiers:(NSNumber*)keyModifiers;

@property (nonatomic, readonly) NSInteger keyCode;
@property (nonatomic, readonly, retain) NSNumber* modifiers;
@property (nonatomic, readonly) NSInteger hotKeyID;

- (BOOL)registerHotKey;
- (BOOL)unregisterHotKey;

@end
