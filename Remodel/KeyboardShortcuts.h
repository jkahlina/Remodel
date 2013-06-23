//
//  KeyboardShortcuts.h
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyboardShortcuts : NSObject
{
	NSMutableArray* _keyboardShortcutsOrder;
	NSInteger _iNextHotKeyID;
}

+ (KeyboardShortcuts*)sharedManager;

- (void)_initializeKeyboardShortcutsOrder;

- (void)_appendKeyboardShortcutToOrder:(NSInteger)identifier;
- (void)addKeyboardShortcut:(NSString*)strName keyCode:(NSInteger)iKeyCode modifiers:(NSNumber*)keyModifiers;
- (void)removeKeyboardShortcut:(NSInteger)iHotKeyID;
- (void)setHotKey:(NSInteger)iHotKeyID activated:(BOOL)bActivated;

- (NSDictionary*)keyboardShortcuts;
- (NSArray*)keyboardShortcutsOrder;

@end
