//
//  LVAutomaticUpdateDriver.m
//  Sparkle
//
//  Created by Kelly Sutton on 5/13/13.
//  Copyright 2013 Kelly Sutton. All rights reserved.
//

#import "LVAutomaticUpdateDriver.h"

#import "SUAutomaticUpdateAlert.h"
#import "SUHost.h"
#import "SUConstants.h"
#import "LVUpdateActivityProtocol.h"

@implementation LVAutomaticUpdateDriver

- (void)unarchiverDidFinish:(SUUnarchiver *)ua
{
    [self installWithToolAndRelaunch:YES];
}

// Override the newer Sparkle DSA/Code-signing requirement. If our SSL cert is compromised, we've got bigger problems.
- (BOOL)validateUpdateDownloadedToPath:(NSString *)downloadedPath extractedToPath:(NSString *)extractedPath DSASignature:(NSString *)DSASignature publicDSAKey:(NSString *)publicDSAKey
{
    return [[updateItem.fileURL scheme] isEqualToString:@"https"] && [[appcastURL scheme] isEqualToString:@"https"];
}


- (void)abortUpdateWithError:(NSError *)error
{
    [super abortUpdateWithError:error];
    if ([updater.delegate conformsToProtocol:@protocol(LVUpdateActivityProtocol)]) {
        id<LVUpdateActivityProtocol> updaterDelegate = (id<LVUpdateActivityProtocol>)updater.delegate;
        [updaterDelegate updateFailedWithError:error];
    }
}

@end
