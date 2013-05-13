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
    if ([lastActiveDate compare:[self fiveMinutesAgo]] == NSOrderedAscending)
        [self installWithToolAndRelaunch:YES];
}

- (NSDate *)fiveMinutesAgo
{
    return [[NSDate date] dateByAddingTimeInterval:-1 * 5 * 60];
}

@end
