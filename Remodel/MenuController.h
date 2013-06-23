//
//  MenuController.h
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"


@interface MenuController : NSObject
{
	IBOutlet NSMenu* _statusMenu;
	IBOutlet NSMenu* _positionWindowMenu;
	NSStatusItem* _statusItem;
	
	PreferencesWindowController* _preferencesWindowController;
}

- (void)setupStatusBarItem;
- (void)addHotKeyItemsToStatusMenu;

- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (void)positionWindow:(id)sender;

- (void)registerForObserverNotifications;
- (void)unregisterForObserverNotifications;
- (void)onSetHotKeyActivated:(NSNotification *)notification;

@end
