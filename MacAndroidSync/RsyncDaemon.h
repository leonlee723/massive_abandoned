//
//  RsyncDaemon.h
//  MacAndroidSync
//
//  Created by winfield on 6/18/11.
//  Copyright 2011 lainuo.info. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RsyncDaemon : NSObject {
@private
    NSString *configFilePath;
}

@property (copy) NSString *configFilePath;

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;
- (NSString *)applicationSupportDirectory;
- (void)generateRsyncdConf;
- (void)addModulesToRsyncdConf:(NSString *)name
                          path:(NSString *)path
                       comment:(NSString *)comment;
- (void)addDefaultModules;

- (void)triggerRsyncDaemon;
- (int)getRsyncDaemonPid;
- (void)killRsyncDaemon;

@end
