//
//  BonjourDiscovery.m
//  MacAndroidSync
//
//  Created by winfield on 7/3/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import "BonjourDiscovery.h"
NSString * const LADeviceDiscoveredNotification = @"LADeviceDiscovered";

@implementation BonjourDiscovery

#pragma mark init, dealloc methods

- (id)init
{
    self = [super init];
    if (self) {
        browser = [[NSNetServiceBrowser alloc] init];
        services = [[NSMutableArray array] retain];
        [browser setDelegate:self];
        [browser searchForServicesOfType:@"_DeviceSyncService._tcp." inDomain:@"local."];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark instances methods

- (void)discoverDevices
{
	[services removeAllObjects];
	
	[browser stop];
	[browser searchForServicesOfType:@"_DeviceSyncService._tcp." inDomain:@"local."];
}

- (NSMutableArray *)services
{
    return services;
}

#pragma mark NSNetServiceBrowser delegates

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    [aNetService resolveWithTimeout:5.0];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSLog(@"Find a Device, now Sending notification");
    [nc postNotificationName:LADeviceDiscoveredNotification object:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [services removeObject:aNetService];
}

@end
