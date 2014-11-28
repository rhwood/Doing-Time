//
//  TFPermissions.m
//  Doing Time
//
//  Created by Randall Wood on 16/4/2012.
//
//  Copyright (c) 2012-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    NSLog(@"Alert button %ld (with title: %@) tapped.", (long)buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingNeverAuthorized forKey:self.userDefaultsKey];
            [TestFlight setOptions:@{@"sendLogOnlyOnCrash": @(YES)}];
            _authorized = NO;
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingAsk forKey:self.userDefaultsKey];
            [TestFlight setOptions:@{@"sendLogOnlyOnCrash": @(NO)}];
            _authorized = YES;
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setInteger:TFLoggingAlwaysAuthorized forKey:self.userDefaultsKey];
            [TestFlight setOptions:@{@"sendLogOnlyOnCrash": @(NO)}];
            _authorized = YES;
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
