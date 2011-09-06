//
//  Command.h
//  MacAndroidSync
//
//  Created by winfield on 7/17/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Command : NSObject {
@private
    NSString *name;
    NSString *value;
}

@property(copy) NSString *name;
@property(copy) id value;

- (id)initWithName:(NSString *)aName value:(id)aValue;
- (NSDictionary *)commandDict;

@end
