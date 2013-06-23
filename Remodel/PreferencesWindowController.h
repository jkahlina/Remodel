//
//  PreferencesWindowController.h
//  Remodel
//
//  Created by Jeff Kahlina on 11-12-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TableViewDataSource.h"

@interface PreferencesWindowController : NSWindowController < NSTableViewDelegate >
{
	IBOutlet NSTabView* _tabView;
	
	IBOutlet NSButton* _btnAccessibilityMakeTrusted;
	IBOutlet NSButton* _btnLaunchAtStartup;
	
	IBOutlet NSTableView* _tableKeyboardShortcuts;
	IBOutlet TableViewDataSource* _dataSource;
}

- (id)init;

- (void)setupKeyboardShortcutTable;

- (void)initializePreferenceValues;
- (void)initializeKeyboardShortcutTable;

- (IBAction)onBtnAccessibilityMakeTrusted:(id)sender;
- (IBAction)onBtnLaunchAtStartup:(id)sender;
- (void)onBtnKeyboardShortcutTableCell:(id)sender;

- (void)registerForObserverNotifications;
- (void)unregisterForObserverNotifications;

- (void)onAddKeyboardShortcut:(NSNotification *)notification;
- (void)onSetHotKeyActivated:(NSNotification *)notification;

@end
