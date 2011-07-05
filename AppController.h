//
//  AppController.h
//  MacAndroidSync
//
//  Created by winfield on 6/14/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RsyncDaemon.h"
#import "BonjourDiscovery.h"

@interface AppController : NSObject {
@private
    IBOutlet NSMenu *theMenu;
    NSStatusItem *statusItem;
    NSImage *itemIcon;
    NSMutableArray *devicesMenuItems;

    RsyncDaemon *rsyncDaemon;
    BonjourDiscovery *discover;
}

- (void)insertDeviceMenuItem:(NSNotification *)note;
- (IBAction)performSync:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)refreshDevises:(id)sender;

@end
