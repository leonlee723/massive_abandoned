//
//  ITunesLibrary.h
//  MacAndroidSync
//
//  Created by winfield on 6/18/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ITunesLibraryParser : NSObject {
@private
    NSString *libraryPath;
    NSDictionary *plist;
    NSDictionary* tracks;
    NSArray *playLists;
    NSMutableArray *artists;
    NSMutableArray *artistsPaths;
}

@property(copy) NSString *libraryPath;
@property(retain) NSDictionary *plist;
@property(retain) NSArray *playLists;
@property(retain) NSDictionary *tracks;
@property(retain) NSMutableArray *artists;
@property(retain) NSMutableArray *artistsPaths;

+ (NSString *)iTunesPath;
+ (BOOL)isInstalled;
+ (NSArray *)findiTunesLibraries;

- (void)getArtistsList;
//- (NSArray *)artists;

@end
