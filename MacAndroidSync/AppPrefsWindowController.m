//
//  AppPrefsWindowController.m
//


#import "AppPrefsWindowController.h"

NSString * const LASyncPaths = @"SyncPaths";
NSString * const LAMenuItems = @"MenuItems";
NSString * const LACachedDevices = @"CachedDevices";


@implementation AppPrefsWindowController
@synthesize artists;
@synthesize artistsPaths;
@synthesize artistsSelection;

- (void)setupToolbar
{
    [self addView:generalPreferenceView label:@"General"];
    [self addView:syncItemsdPreferenceView label:@"Sync Items"];
	[self addView:advancedPreferenceView label:@"Advanced"];

    
    iTunesLibraryParsers = [ITunesLibraryParser findiTunesLibraries];
    for (ITunesLibraryParser *paser in iTunesLibraryParsers) {
        [paser getArtistsList];
    }
    
    iTunesLibraryParser = [iTunesLibraryParsers objectAtIndex:0];
    artists = [[NSArray alloc] initWithArray:[iTunesLibraryParser artists]];
    artistsPaths = [[NSArray alloc] initWithArray:[iTunesLibraryParser artistsPaths]];
    artistsSelection = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *syncPaths = [[defaults objectForKey:LASyncPaths] autorelease];
    for (int i = 0; i < [artists count]; i++) {
        if ([syncPaths containsObject:[artists objectAtIndex:i]]) {
            [artistsSelection addObject:[NSNumber numberWithBool:YES]];
        } else {
            [artistsSelection addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
}

#pragma mark tableView datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [artists count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqual:@"artists"]) {
        return [artists objectAtIndex:row];
    } else {
        return [artistsSelection objectAtIndex:row];
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    [artistsSelection replaceObjectAtIndex:row withObject:object];
    
    if ([object boolValue] == YES) {
        NSLog(@"add path to user defaults");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *syncPaths = [NSMutableArray arrayWithArray:[defaults objectForKey:LASyncPaths]];
        
        [syncPaths addObject:[artistsPaths objectAtIndex:row]];
        [defaults setObject:syncPaths forKey:LASyncPaths];
    }
    
    if ([object boolValue] == NO) {
        NSLog(@"remove path to user defaults");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *syncPaths = [NSMutableArray arrayWithArray:[defaults objectForKey:LASyncPaths]];
        
        [syncPaths removeObject:[artistsPaths objectAtIndex:row]];
        [defaults setObject:syncPaths forKey:LASyncPaths];
    }
}

@end
