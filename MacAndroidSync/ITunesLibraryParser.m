//
//  ITunesLibrary.m
//  MacAndroidSync
//
//  Created by winfield on 6/18/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import "ITunesLibraryParser.h"


@implementation ITunesLibraryParser
@synthesize libraryPath;
@synthesize plist;
@synthesize playLists;
@synthesize tracks;

+ (NSString *)iTunesPath
{
    NSWorkspace *workSpace = [[[NSWorkspace alloc] init] autorelease];
    return [workSpace absolutePathForAppBundleWithIdentifier:@"com.apple.iTunes"];
}

+ (BOOL)isInstalled
{
    return [self iTunesPath] != nil;
}

// Look at the iApps preferences file and find all iTunes libraries. Create a parser instance for each libary...

+ (NSArray *)findiTunesLibraries
{
    NSMutableArray *parserInstances = [NSMutableArray array];
    
    if ([self isInstalled]) {
        CFArrayRef recentLibraries = CFPreferencesCopyAppValue((CFStringRef)@"iTunesRecentDatabases", (CFStringRef)@"com.apple.iApps");
		NSArray *libraries = (NSArray *)recentLibraries;
        
        for (NSString *library in libraries)
		{
			NSURL *url = [NSURL URLWithString:library];
			NSString *libraryPath = [url path];
            
			ITunesLibraryParser *parser = [[[self class] alloc] init];
			parser.libraryPath = libraryPath;
			[parserInstances addObject:parser];
			[parser release];
		}
        
        if (recentLibraries) {
            CFRelease(recentLibraries);
        }
    }
    
    return parserInstances;
}

- (id)init
{
    self = [super init];
    if (self) {
        plist = [NSDictionary dictionaryWithContentsOfFile:libraryPath];
        playLists = [plist objectForKey:@"Playlists"];
        tracks = [plist objectForKey:@"Tracks"];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)musicFolder
{
    NSURL *url = [NSURL URLWithString:[plist objectForKey:@"Music Folder"]];
    return [url path];
}

- (NSArray *)artists
{
    NSMutableArray *artistsArray = [NSMutableArray array];
    for (NSDictionary *track in tracks) {
        NSString *artistName = [track objectForKey:@"Artist"];
        // artist alrealy in the array
        if ([artistsArray containsObject:artistName]) {
            continue;
        }
        
        // new artist
        [artistsArray addObject:artistName];
    }
    return artistsArray;
}

@end
