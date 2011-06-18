//
//  AppController.h
//  MacAndroidSync
//
//  Created by winfield on 6/14/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RsyncDaemon.h"
//@class RsyncDaemon;

@interface AppController : NSObject {
@private
    IBOutlet NSMenu *theMenu;
    NSStatusItem *statusItem;
    NSImage *itemIcon;

    RsyncDaemon *rsyncDaemon;
}

- (IBAction)openPreferences:(id)sender;
- (IBAction)quitApp:(id)sender;
@end
