//
//  MacAndroidSyncAppDelegate.h
//  MacAndroidSync
//
//  Created by winfield on 6/14/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MacAndroidSyncAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
