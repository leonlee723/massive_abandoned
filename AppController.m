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
        rsyncDaemon = [[RsyncDaemon alloc] init];
        [rsyncDaemon generateRsyncdConf];
        [rsyncDaemon triggerRsyncDaemon];
        [rsyncDaemon getRsyncDaemonPid];
    }
    
    return self;
}

- (void)dealloc
{
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

- (IBAction)openPreferences:(id)sender
{
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction)quitApp:(id)sender
{
    [rsyncDaemon killRsyncDaemon];
    [NSApp terminate:nil];
}

@end
