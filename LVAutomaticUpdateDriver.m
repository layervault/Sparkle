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

@implementation LVAutomaticUpdateDriver

- (void)unarchiverDidFinish:(SUUnarchiver *)ua
{
    [self performUpdateIfInactive];
}

- (void)performUpdateIfInactive
{
    SEL lastActivitySelector = sel_registerName("lastActivity");
    if (!updater.delegate || ![updater.delegate respondsToSelector:lastActivitySelector])
        return;

    NSDate *lastActiveDate = [updater.delegate performSelector:lastActivitySelector];

    // Make sure something hasn't happened between the time we asked for an update and we unarchived the update.
    if (lastActiveDate && [lastActiveDate compare:[self timeAgoThreshold]] == NSOrderedAscending)
        [self installWithToolAndRelaunch:YES];
}

- (NSDate *)timeAgoThreshold
{
    SEL updateThresholdSelector = sel_registerName("updateThreshold");
    if (updater.delegate && [updater.delegate respondsToSelector:updateThresholdSelector]) {
        return [[NSDate date] dateByAddingTimeInterval:-1 * (int)[updater.delegate performSelector:updateThresholdSelector]];
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


@end
