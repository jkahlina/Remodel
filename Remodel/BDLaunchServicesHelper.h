//
//  BDLaunchServicesHelper.h
//  MIT license: http://www.bdunagan.com/2010/09/25/cocoa-tip-enabling-launch-on-startup/
//

#import <Cocoa/Cocoa.h>


@interface BDLaunchServicesHelper : NSObject {

}

+ (BOOL)isLaunchAtStartup;
+ (LSSharedFileListItemRef)itemRefInLoginItems;
+ (void)toggleLaunchAtStartup;

@end
