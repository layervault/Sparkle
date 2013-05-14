# AutoSparkle 
is an easy-to-use software update framework for Cocoa developers with silent updates.

This is a fork of [Andy Matuschak's Sparkle framework](https://github.com/andymatuschak/Sparkle) with one important difference: it 
allows for automatic, silent updates. For an application like [LayerVault](https://layervault.com), we have the app update during 
periods of inactivity. For system toolbar apps, this is some great behavior.

Please see the original Sparkle framework for instructions on getting Sparkle setup for your project.

Let's talk about setting up AutoSparkle.

## Setup

You need to implement the `LVUpdateActivityProtocol`, like so:

```Objective-C
// MyChecker.h
@class MyChecker : NSObject<LVUpdateActivityProtocol>
@end

// MyChecker.m
static const NSTimeInterval kUpdateCheckFrequency = 5 * 60;
@implementation MyChecker
- (NSDate *)lastActivity
{
    return _lastActivity; // NSDate of the last user-performed action.
}

- (NSTimeInterval)updateThreshold
{
    return kUpdateCheckFrequency;
}
@end 
```

Next up, it's up to you to call `checkForUpdatesAndInstallAutomatically:` as you please. Here's how we do it:

```Objective-C
// AppDelegate.m
- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    [self resetActivityTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetActivityTimer)
                                                 name:@"LVActivityReceived"
                                               object:nil];
}

- (void)resetActivityTimer
{
    _lastActivity = [NSDate date];
    if (_lastActivityTimer) {
        [_lastActivityTimer invalidate];
        _lastActivityTimer = nil;
    }
    
    _lastActivityTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateCheckFrequency
                                                          target:self
                                                        selector:@selector(checkForUpdates)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)checkForUpdates
{
    [[SUUpdater sharedUpdater] checkForUpdatesAndInstallAutomatically:self];
}
```

Boom. `checkForUpdatesAndInstallAutomatically` initializes a new `LVAutomaticUpdateDriver` instance and lets that do the heavy lifting.
If an update it found, it performs a check to make sure the user hasn't done anything while we were downloading and 
unpacking the update. If we're still in the clear, the new version of the application gets installed.

You should [take a look the source for `LVAutomaticUpdateDriver.m`](https://github.com/layervault/Sparkle/blob/master/LVAutomaticUpdateDriver.m).

Enjoy!
