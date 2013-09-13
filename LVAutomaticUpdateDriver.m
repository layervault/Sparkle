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
    [self performUpdateIfInactive];
}

- (void)performUpdateIfInactive
{
    if ([updater.delegate conformsToProtocol:@protocol(LVUpdateActivityProtocol)]) {
        id<LVUpdateActivityProtocol> updaterDelegate = (id<LVUpdateActivityProtocol>)updater.delegate;
        NSDate *lastActiveDate = [updaterDelegate lastActivity];

        // Make sure something hasn't happened between the time we asked for an update and we unarchived the update.
        if (lastActiveDate && [lastActiveDate compare:[self timeAgoThreshold]] == NSOrderedAscending) {
            [self installWithToolAndRelaunch:YES];
        }
    }
}

- (NSDate *)timeAgoThreshold
{
    if ([updater.delegate conformsToProtocol:@protocol(LVUpdateActivityProtocol)]) {
        id<LVUpdateActivityProtocol> updaterDelegate = (id<LVUpdateActivityProtocol>)updater.delegate;
        return [[NSDate date] dateByAddingTimeInterval:-1 * (int)[updaterDelegate updateThreshold]];
    }
    else {
        return [[NSDate date] dateByAddingTimeInterval:-1 * 5 * 60];
    }
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
