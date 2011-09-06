//
//  Command.m
//  MacAndroidSync
//
//  Created by winfield on 7/17/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import "Command.h"


@implementation Command
@synthesize name;
@synthesize value;

- (id)init
{
    return [self initWithName:@"default" value:@"OK"];
}

- (id)initWithName:(NSString *)aName value:(id)aValue
{
    self = [super init];
    if (self) {
        name = aName;
        value = aValue;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSDictionary *)commandDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:@"name"];
    [dict setObject:value forKey:@"value"];
    
    return dict;
}

@end
