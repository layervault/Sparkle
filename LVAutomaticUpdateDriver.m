//
//  SUAutomaticUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
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


@end
