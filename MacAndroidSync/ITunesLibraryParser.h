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
    NSArray *artists;
}

@property(copy) NSString *libraryPath;
@property(retain) NSDictionary *plist;
@property(retain) NSArray *playLists;
@property(retain) NSDictionary* tracks;

@end
