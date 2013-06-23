//
//  RemodelAppDelegate.h
//  Remodel
//
//  Created by Jeff on 12/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardHooks.h"
#import "MenuController.h"


@interface RemodelAppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet MenuController* _menuController;
	KeyboardHooks* _keyboardHooks;
}

- (void)startStopKeyboardHooks:(BOOL)bStart;
- (void)setupLaunchAtStartupIfNecessary;

+ (void)setupDefaults;

@end
