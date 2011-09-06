//
//  AppController.m
//  MacAndroidSync
//
//  Created by winfield on 6/14/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#import "AppController.h"
#import "AppPrefsWindowController.h"
#import "RsyncDaemon.h"
#import "JSONKit.h"
#import "Command.h"
#import "MASDropzoneView.h"
    

@implementation AppController
//@synthesize configFilePath;

+ (void)initialize
{
    // Create a dictionaryperform sync with Hero
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    NSArray *defaultSyncPaths = [NSArray array];
    
    // Put defaults in the dictionary
    [defaultValues setObject:defaultSyncPaths forKey:LASyncPaths];
    
    // Register the dictionary of defaults
    [[NSUserDefaults standardUserDefaults]
     registerDefaults: defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}

#pragma mark init, dealloc method

- (id)init
{
    self = [super init];
    if (self) {
        devicesMenuItems = [[NSMutableArray alloc] init];
        devicesAddresses = [[NSMutableArray alloc] init];
        discover = [[BonjourDiscovery alloc] init];
        rsyncDaemon = [[RsyncDaemon alloc] init];
        [rsyncDaemon generateRsyncdConf];
        [rsyncDaemon triggerRsyncDaemon];
        [rsyncDaemon getRsyncDaemonPid];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(receiveDeviceFoundNotification:)
                   name:LADeviceDiscoveredNotification
                 object:nil];
        NSLog(@"Registered with notification center");
    }
    
    return self;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [discover dealloc];
    [devicesMenuItems dealloc];
    [super dealloc];
}

#pragma mark awakeFromNib

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar] 
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setHighlightMode:YES];
    
    //  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *itemIconPath = [bundle pathForImageResource:@"StatusItem"];
    itemIcon = [[NSImage alloc] initWithContentsOfFile:itemIconPath];
    
    [statusItem setTitle:[NSString stringWithFormat:@""]];
    [statusItem setImage:itemIcon];
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"Android Mac Sync"];
    [statusItem setMenu:theMenu];
    
    // set custom view 
    MASDropzoneView *statusItemView = [[[MASDropzoneView alloc] init] retain];
    [statusItem setView: statusItemView];  
    
    [self checkDeviceAliveWhenAwake];
}

#pragma mark instances methods

- (void)receiveDeviceFoundNotification:(NSNotification *)note
{
    NSLog(@"Received Notification: %@", note);
    
    NSNetService *service = (NSNetService *)[note object];
    [service setDelegate:self];
    [service resolveWithTimeout:5.0];
}

- (void)insertDeviceMenuItem:(NSDictionary *)deviceSocketInfo
{
    NSLog(@"Insert Menu Item");
   
//    NSString *deviceName = [NSString stringWithFormat:@"%@", [service name]];
    NSString *deviceName = [NSString stringWithFormat:@"%@", [deviceSocketInfo objectForKey:@"name"]];
    NSString *deviceMenuDisplay = [NSString stringWithFormat:@"Sync with %@", deviceName];
    NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:deviceMenuDisplay
                                                      action:@selector(performSync:)
                                                keyEquivalent:@""] autorelease];
    [menuItem setTarget:self];
    [menuItem setRepresentedObject:deviceSocketInfo];
//    [menuItem setRepresentedObject:service];
    [devicesMenuItems addObject:menuItem];
    [theMenu insertItem:menuItem atIndex:3];
    [devicesAddresses addObject:deviceSocketInfo];
//    [devicesAddresses addObjectsFromArray:deviceSocketInfo];
    
    NSLog(@"Insert Menu Item: devicesMenuItems count is %lu", [devicesMenuItems count]);
    NSLog(@"Insert Menu Item: cache menuitems to user defaults");
    NSLog(@"devicesAddress count: %lu", [devicesAddresses count]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setObject:devicesAddresses forKey:LACachedDevices];
}

#pragma mark actions

- (IBAction)performSync:(id)sender;
{
    NSArray *menuItemTitleArray = [[(NSMenuItem *)sender title] componentsSeparatedByString:@" "];
    NSString *deviseName = [NSString stringWithFormat:@"%@", [menuItemTitleArray lastObject]];
    NSLog(@"perform sync with %@", deviseName);
//    NSNetService *service = nil;
//    NSDictionary *device = nil;
//    id representedObject = [(NSMenuItem *)sender representedObject];
//    if ([representedObject isKindOfClass:[NSNetService class]]) {
//        service = [(NSMenuItem *)sender representedObject];
//    } else if ([representedObject isKindOfClass:[NSDictionary class]]) {
//        device = [(NSMenuItem *)sender representedObject];
//    }
//
//	NSData *appData = [@"kkkk" dataUsingEncoding:NSUTF8StringEncoding];
//	
//	if (service) {
//		NSOutputStream *outStream;
//		[service getInputStream:nil outputStream:&outStream];
//		[outStream open];
//		NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
//		[outStream close];
//		
//		NSLog(@"NetService Wrote %ld bytes", bytes);
//	} else if (device) {
//        NSHost *host = [NSHost hostWithName:[device objectForKey:@"host"]];
//        NSOutputStream *outStream;
//        [NSStream getStreamsToHost:host port:[[device objectForKey:@"port"] intValue] inputStream:nil outputStream:&outStream];
//        [outStream open];
//        
//        NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
//        NSLog(@"not NSNetService Wrote %ld bytes", bytes);
//        [outStream close];
//    }
    NSDictionary *deviceSocketInfo = [(NSMenuItem *)sender representedObject];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *syncPaths = [[defaults objectForKey:LASyncPaths] autorelease];
    
    Command *aCommand = [[[Command alloc] initWithName:@"sync" value:syncPaths] autorelease];
    [self sendToAndroidWithoutNetService:deviceSocketInfo withCommand:aCommand];
}

- (IBAction)openPreferences:(id)sender
{
    NSLog(@"open prefs");
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)quitApp:(id)sender
{
    [rsyncDaemon killRsyncDaemon];
    [NSApp terminate:nil];
}

- (IBAction)refreshDevises:(id)sender
{
    NSLog(@"refresh devises");
    NSLog(@"the menu items count now: %lu", [devicesMenuItems count]);
    Command *aCommand = [[[Command alloc] initWithName:@"CheckAlive" value:@"None"] autorelease];
    for (NSMenuItem *menuItem in devicesMenuItems) {
        NSInteger bytes;
        
//        id representedObject = [menuItem representedObject];
//        if ([representedObject isKindOfClass:[NSNetService class]]) {
//            NSLog(@"it's a net service class");
//            bytes = [self sendToAndroid:representedObject withCommand:aCommand];
//        } else if ([representedObject isKindOfClass:[NSDictionary class]]) {
//            NSLog(@"it's a not net service class");
//            bytes = [self sendToAndroidWithoutNetService:representedObject withCommand:aCommand];
//        } else
//            NSLog(@"what the hell it is? : %@", [representedObject class]);
        
        bytes = [self sendToAndroidWithoutNetService:[menuItem representedObject] withCommand:aCommand];
        
        if (bytes < 0) {
            NSLog(@"the devise has died, what a pity...");
            [theMenu removeItem:menuItem];
            [devicesMenuItems removeObject:menuItem];
        } else
            NSLog(@"existing device still alive");
    }
    
//    [devicesMenuItems removeAllObjects];
    [discover discoverDevices];    
}

#pragma mark helpers

- (void)checkDeviceAliveWhenAwake
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [devicesAddresses addObjectsFromArray:[defaults objectForKey:LACachedDevices]];
    Command *aCommand = [[[Command alloc] initWithName:@"CheckAlive" value:@"None"] autorelease];
    NSLog(@"the cached devices count: %lu", [devicesAddresses count]);
    NSMutableIndexSet *diedDeviceIndexs = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [devicesAddresses count]; i++) {
//    for (NSDictionary *device in devicesAddresses) {
        NSLog(@"damn it!");
        NSDictionary *deviceSocketInfo = [devicesAddresses objectAtIndex:i];
        
        NSInteger bytes = [self sendToAndroidWithoutNetService:deviceSocketInfo withCommand:aCommand];
        if (bytes >= 0) {
            NSLog(@"device still alive");
            NSString *deviceName = [NSString stringWithFormat:@"%@", [deviceSocketInfo objectForKey:@"name"]];
            NSString *deviceMenuDisplay = [NSString stringWithFormat:@"Sync with %@", deviceName];
            NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:deviceMenuDisplay
                                                               action:@selector(performSync:)
                                                        keyEquivalent:@""] autorelease];
            [menuItem setTarget:self];
            [menuItem setRepresentedObject:deviceSocketInfo];
            [devicesMenuItems addObject:menuItem];
            [theMenu insertItem:menuItem atIndex:3];
        } else {
            NSLog(@"the device seems died");
            [diedDeviceIndexs addIndex:i];
        }
    }
    
    [devicesAddresses removeObjectsAtIndexes:diedDeviceIndexs];
    [defaults setObject:devicesAddresses forKey:LACachedDevices];
}

- (BOOL)checkDeviceDup:(NSDictionary *)deviceSocketInfo
{
    if ([devicesAddresses containsObject:deviceSocketInfo]) {
        return true;
    }
    return false;
}

- (NSInteger)sendToAndroid:(NSNetService *)netService withCommand:(Command *)aCommand
{
    NSDictionary *commandDict = [aCommand commandDict];
    NSData *appData = [commandDict JSONData];
    NSString *appDataString = [commandDict JSONString];
    NSLog(@"The app data: %@", appDataString);
    
    NSOutputStream *outStream;
    [netService getInputStream:nil outputStream:&outStream];
    [outStream open];
    NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
    [outStream close];
    
    NSLog(@"Wrote %ld bytes", bytes);
    return bytes;
}

- (NSInteger)sendToAndroidWithoutNetService:(NSDictionary *)device withCommand:(Command *)aCommand
{
    NSDictionary *commandDict = [aCommand commandDict];
    NSData *appData = [commandDict JSONData];
    NSString *appDataString = [commandDict JSONString];
    NSLog(@"The app data: %@", appDataString);
    
    NSHost *host = [NSHost hostWithName:[device objectForKey:@"host"]];
    NSOutputStream *outStream;
    [NSStream getStreamsToHost:host port:[[device objectForKey:@"port"] intValue] inputStream:nil outputStream:&outStream];
    [outStream open];    
    NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
    [outStream close];
    
    NSLog(@"Wrote %ld bytes", bytes);
    return bytes;
}

- (NSArray *)getDeviceSocketInfo:(NSNetService *)service
{
    NSMutableArray *serviceSockets = [NSMutableArray array];
    
    for (NSData* data in [service addresses]) {
        NSMutableDictionary *socketInfo = [NSMutableDictionary dictionary];
        char addressBuffer[100];
        struct sockaddr_in *socketAddress = (struct sockaddr_in *)[data bytes];
        
        int sockFamily = socketAddress -> sin_family;        
        if (sockFamily == AF_INET || sockFamily == AF_INET6) {
            
//            const char *addressStr = inet_ntop(sockFamily,
//                                               &(socketAddress->sin_addr), addressBuffer,
//                                               sizeof(addressBuffer));
            inet_ntop(sockFamily, &(socketAddress->sin_addr), addressBuffer, sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sin_port);
            
            if (addressBuffer && port) {
//                NSLog(@"Found service at %s:%d", addressStr, port);
                NSLog(@"Found service at %s:%d", addressBuffer, port);
                NSString *host = [[[NSString alloc] initWithUTF8String:addressBuffer] autorelease];
                [socketInfo setObject:host forKey:@"host"];
                [socketInfo setObject:[NSString stringWithFormat:@"%d", port] forKey:@"port"];
                [socketInfo setObject:[NSString stringWithFormat:@"%@", [service name]] forKey:@"name"];
                [serviceSockets addObject:socketInfo];
            }
            
        }
        
    }
    NSLog(@"serviceSockets count: %ld", [serviceSockets count]);
    return serviceSockets;
}

#pragma mark NSNetServiceDelegate methods

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"service resolved");
    
    // now we just get the first element of the array, we will look into how to deal with it later
    NSArray *deviceSocketInfos = [self getDeviceSocketInfo:sender];
    NSDictionary *deviceSocketInfo = [deviceSocketInfos objectAtIndex:0]; 
    
    Command *aCommand = [[[Command alloc] initWithName:@"deviceFinded" value:@"OK"] autorelease];
    NSInteger bytes = [self sendToAndroidWithoutNetService:deviceSocketInfo withCommand:aCommand];
    if (bytes < 0) {
        NSLog(@"oops...send again");
        bytes = [self sendToAndroidWithoutNetService:deviceSocketInfo withCommand:aCommand];
        
        if (bytes < 0) {
            NSLog(@"somthing very bad happened...damn!");
        } else {
            NSLog(@"finally got the device infomed!");
        }
    } else {
        NSLog(@"informed device to stop jmDNS service");
    }
    
    if ([self checkDeviceDup:deviceSocketInfo]) {
        NSLog(@"Duped! The Device Already Here.");
        return;
    } else {
        [self insertDeviceMenuItem:deviceSocketInfo];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"service resolve failed");
}

@end
