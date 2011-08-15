//
//  AppPrefsWindowController.h
//


#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "ITunesLibraryParser.h"

extern NSString * const LASyncPaths;
extern NSString * const LAMenuItems;
extern NSString * const LACachedDevices;

@interface AppPrefsWindowController : DBPrefsWindowController <NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet NSView *generalPreferenceView;
    IBOutlet NSView *syncItemsdPreferenceView;
	IBOutlet NSView *advancedPreferenceView;
    
    IBOutlet NSTableView *artistsTableView;
    
    NSArray *iTunesLibraryParsers;
    ITunesLibraryParser *iTunesLibraryParser;
    NSArray *artists;
    NSArray *artistsPaths;
    NSMutableArray *artistsSelection;
}

@property(retain) NSArray *artists;
@property(retain) NSArray *artistsPaths;
@property(retain) NSMutableArray *artistsSelection;

@end
