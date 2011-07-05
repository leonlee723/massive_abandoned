//
//  AppController.m
//  MacAndroidSync
//
//  Created by winfield on 6/14/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import "AppController.h"
#import "AppPrefsWindowController.h"
#import "RsyncDaemon.h"

@implementation AppController
//@synthesize configFilePath;

- (id)init
{
    self = [super init];
    if (self) {
        devicesMenuItems = [[NSMutableArray alloc] init];
        discover = [[BonjourDiscovery alloc] init];
        rsyncDaemon = [[RsyncDaemon alloc] init];
        [rsyncDaemon generateRsyncdConf];
        [rsyncDaemon triggerRsyncDaemon];
        [rsyncDaemon getRsyncDaemonPid];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(insertDeviceMenuItem:)
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
}

- (void)insertDeviceMenuItem:(NSNotification *)note
{
    NSLog(@"Received notification: %@", note);

    NSString *deviceName = [NSString stringWithFormat:@"%@", [(NSNetService *)[note object] name]];
    NSString *deviceMenuDisplay = [NSString stringWithFormat:@"Sync with %@", deviceName];
    NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:deviceMenuDisplay
                                                      action:@selector(performSync:)
                                                keyEquivalent:@""] autorelease];
    [menuItem setTarget:self];
    [devicesMenuItems addObject:menuItem];
    [theMenu insertItem:menuItem atIndex:3];
}

- (IBAction)performSync:(id)sender;
{
    NSArray *menuItemTitleArray = [[(NSMenuItem *)sender title] componentsSeparatedByString:@" "];
    NSString *deviseName = [NSString stringWithFormat:@"%@", [menuItemTitleArray lastObject]];
    NSLog(@"perform sync with %@", deviseName);    
}

- (IBAction)openPreferences:(id)sender
{
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction)quitApp:(id)sender
{
    [rsyncDaemon killRsyncDaemon];
    [NSApp terminate:nil];
}

- (IBAction)refreshDevises:(id)sender
{
    NSLog(@"refresh devises");
    for (NSMenuItem *menuItem in devicesMenuItems) {
        [theMenu removeItem:menuItem];
    }
    [devicesMenuItems removeAllObjects];
    [discover discoverDevices];    
}
@end
