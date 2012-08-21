//
//  TFPermissions.m
//  Doing Time
//
//  Created by Randall Wood on 16/4/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "TFLoggingManager.h"

typedef enum {
    TFLoggingUnknown = 0,
    TFLoggingAsk = 1,
    TFLoggingAlwaysAuthorized = 2,
    TFLoggingNeverAuthorized = 3
} TFLoggingAuthorizations;

@implementation TFLoggingManager

@synthesize userDefaultsKey;
@synthesize requestTitle;
@synthesize requestMessage;
@synthesize authorized = _authorized;

+ (TFLoggingManager *)sharedInstance {
    static TFLoggingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TFLoggingManager alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    if ((self = [super init])) {
        self.userDefaultsKey = @"TFLoggingAuthorized";
        self.requestTitle = NSLocalizedString(@"Error Report", @"TFLogging Request Authorization Title");
        self.requestMessage = NSLocalizedString(@"This app has detected an error. Would you like to provide the developer anonymous error data so they can try to fix the problem?", @"TFLogging Request Authorization Message");
        _authorized = ([[NSUserDefaults standardUserDefaults] integerForKey:self.userDefaultsKey] == TFLoggingAlwaysAuthorized);
    }
    return self;
}

- (Boolean) authorized {
    return _authorized;
}

- (void) requestAuthorization {
    if (!self.authorized && [[NSUserDefaults standardUserDefaults] integerForKey:self.userDefaultsKey] != TFLoggingNeverAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.requestTitle
                                                        message:self.requestMessage
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Don't Send", @"TFLogging Request Authorization Cancel")
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"Send", @"TFLogging Request Authorization Send Once")];
        [alert addButtonWithTitle:NSLocalizedString(@"Always Send", @"TFLogging Request Authorization Always")];
        [alert show];
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    // nothing to do, but this method signature prevents cancelling the alert from equalling pressing the Don't Send button
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert button %d (with title: %@) tapped.", buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingNeverAuthorized forKey:self.userDefaultsKey];
            [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"sendLogOnlyOnCrash"]];
            _authorized = NO;
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingAsk forKey:self.userDefaultsKey];
            [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"sendLogOnlyOnCrash"]];
            _authorized = YES;
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingAlwaysAuthorized forKey:self.userDefaultsKey];
            [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"sendLogOnlyOnCrash"]];
            _authorized = YES;
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
