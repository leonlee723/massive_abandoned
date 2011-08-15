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
#import "Command.h"

@interface AppController : NSObject <NSNetServiceDelegate> {
@private
    IBOutlet NSMenu *theMenu;
    NSStatusItem *statusItem;
    NSImage *itemIcon;
    NSMutableArray *devicesMenuItems;
    NSMutableArray *devicesAddresses;

    RsyncDaemon *rsyncDaemon;
    BonjourDiscovery *discover;
}

- (void)receiveDeviceFoundNotification:(NSNotification *)note;
- (void)insertDeviceMenuItem:(NSDictionary *)deviceSocketInfo;
- (IBAction)performSync:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quitApp:(id)sender;
- (IBAction)refreshDevises:(id)sender;

- (void)checkDeviceAliveWhenAwake;
- (BOOL)checkDeviceDup:(NSDictionary *)deviceSocketInfo;
- (NSInteger)sendToAndroid:(NSNetService *)netService withCommand:(Command *)aCommand;
- (NSInteger)sendToAndroidWithoutNetService:(NSDictionary *)device withCommand:(Command *)aCommand;
- (NSArray *)getDeviceSocketInfo:(NSNetService *)service;

@end
