//
//  BonjourDiscovery.h
//  MacAndroidSync
//
//  Created by winfield on 7/3/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const LADeviceDiscoveredNotification;

@interface BonjourDiscovery : NSObject <NSNetServiceBrowserDelegate> {
@private
    NSNetServiceBrowser		*browser;
	NSMutableArray			*services;
}

- (void)discoverDevices;
- (NSMutableArray *)services;

@end
