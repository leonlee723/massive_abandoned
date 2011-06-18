//
//  RsyncDaemon.m
//  MacAndroidSync
//
//  Created by winfield on 6/18/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import "RsyncDaemon.h"


@implementation RsyncDaemon
@synthesize configFilePath;

- (id)init
{
    self = [super init];
    if (self) {
        configFilePath = [[[self applicationSupportDirectory] 
                           stringByAppendingString:@"/rsyncd.conf"] retain];
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [configFilePath release];
    [super dealloc];
}

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask appendPathComponent:(NSString *)appendComponent error:(NSError **)errorOut
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
    if ([paths count] == 0) {
        // error handling
        return nil;
    }
    NSString *resolvedPath = [paths objectAtIndex:0];
    if (appendComponent) {
        resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
    }
    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:resolvedPath isDirectory:&isDirectory];
    
    if (!exists || !isDirectory) {
        if (exists) {
            // error handling
            return nil;
        }
        NSError *error;
        BOOL success = [fileManager createDirectoryAtPath:resolvedPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        if (!success) {
            if (errorOut) {
                *errorOut = error;
            }
            return nil;
        }
    }
    
    return resolvedPath;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] 
                                objectForKey:@"CFBundleExecutable"];
    NSError *error;
    NSString *result = [self findOrCreateDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                               appendPathComponent:executableName
                                             error:&error];
    return result;
}



- (void)generateRsyncdConf
{
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL exists = [fileManager fileExistsAtPath:configFilePath];
    if (exists) {
        return;
    }
    
    NSString *pidFileConf = [NSString stringWithFormat:@"pid file = %@/rsyncd.pid\n", 
                             [self applicationSupportDirectory]];
    NSString *portConf = [NSString stringWithFormat:@"port = %d\n", 5985];
    NSString *basiConfs = [pidFileConf stringByAppendingString:portConf];
    
    NSError *error;
    BOOL success = [basiConfs writeToFile:configFilePath
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
    if (!success) {
        //error handling
    }
}

- (void)addDefaultModules
{
}

- (void)addModulesToRsyncdConf:(NSString *)name path:(NSString *)path comment:(NSString *)comment
{
    NSString *moduleName = [NSString stringWithFormat:@"[%@]\n", name];
    NSString *modulePath = [NSString stringWithFormat:@"path = %@\n", path];
    NSString *moduleComment = [NSString stringWithFormat:@"comment = %@\n", comment];
    NSString *moduleConf = [moduleName stringByAppendingString:[modulePath stringByAppendingString:moduleComment]];
    NSData *moduleConfData = [moduleConf dataUsingEncoding:NSUTF8StringEncoding];
    
    NSFileHandle *rsyncdConfigFile = [NSFileHandle fileHandleForWritingAtPath:configFilePath];
    [rsyncdConfigFile seekToEndOfFile];
    [rsyncdConfigFile writeData:moduleConfData]; 
}

- (void)triggerRsyncDaemon
{
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:@"/usr/bin/rsync"];    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"--daemon", @"--config", configFilePath, nil];
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *standardOutputFile = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [standardOutputFile readDataToEndOfFile];
    NSString *returnString = [[[NSString alloc] initWithData:data 
                                                    encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"returned: %@", returnString);
}

- (int)getRsyncDaemonPid
{
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:@"/usr/sbin/lsof"];    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-i", @":5985", nil];
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *standardOutputFile = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [standardOutputFile readDataToEndOfFile];
    NSString *returnString = [[[NSString alloc] initWithData:data 
                                                    encoding:NSUTF8StringEncoding] autorelease];
    
    NSArray *lines = [returnString componentsSeparatedByString:@"\n"];
    NSArray *processInfos = [[[NSArray alloc] init] autorelease];
    if ([lines count] > 2) {
        NSString *line = [lines objectAtIndex:1];
        processInfos = [line componentsSeparatedByString:@" "];
    }
    
    return [[processInfos objectAtIndex:3] intValue];
}

- (void)killRsyncDaemon
{
    int pid = [self getRsyncDaemonPid];
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:@"/bin/sh"];    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c", 
                          [NSString stringWithFormat:@"kill -9 %d", pid], nil];
    [task setArguments:arguments];
    [task launch];
    NSLog(@"process pid: %d", [task processIdentifier]);
}

@end
