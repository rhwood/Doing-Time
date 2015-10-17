//
//  Doing_TimeAppDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//
//  Copyright (c) 2010-2014 Randall Wood
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

#import "Doing_TimeAppDelegate.h"
#import "MainViewController.h"
#import "EventViewController.h"
#import "AppStoreDelegate.h"
#import "CargoBay.h"

@implementation Doing_TimeAppDelegate

@synthesize window;
@synthesize mainViewController;
//@synthesize eventStore = _eventStore;
@synthesize appStore = _appStore;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    _red = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1.0];
    _green = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
    _blue = [UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:1.0];
    _white = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

	//self.eventStore = [[EKEventStore alloc] init];
	
	// Migrate from version 1 settings to version 2 settings
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Title"]) {
        NSMutableDictionary *activity = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                             titleKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"Title"],
                                                                             startKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"],
                                                                               endKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"]}];
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Link"]) {
			[activity setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"Link"] forKey:linkKey];
		}
		NSArray *activities = @[activity];
		[[NSUserDefaults standardUserDefaults] setObject:activities forKey:eventsKey];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Title"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Start Date"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"End Date"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Link"];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}

    // Migrate from version 2 settings to version 3 settings
    if ([[NSUserDefaults standardUserDefaults] integerForKey:versionKey] < 3) {
        BOOL showCompletedDays = YES;
        if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] valueForKey:showCompletedDaysKey]) {
            showCompletedDays = [[NSUserDefaults standardUserDefaults] boolForKey:showCompletedDaysKey];
        }
        BOOL showPercentage = NO;
        if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] valueForKey:showPercentageKey]) {
            showPercentage = [[NSUserDefaults standardUserDefaults] boolForKey:showPercentageKey];
        }
        NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
        for (int i = 0; i < events.count; i++) {
            NSMutableDictionary *event = [events objectAtIndex:i];
            [event setValue:@(showCompletedDays) forKey:showCompletedDaysKey];
            [event setValue:@(showPercentage) forKey:showPercentageKey];
            [event setValue:@(YES) forKey:showTotalsKey];
            [event setValue:@(([[event valueForKey:dayOverKey] boolValue]) ? todayIsOver : todayIsRemaining) forKey:todayIsKey];
            [event removeObjectForKey:dayOverKey];
            [events replaceObjectAtIndex:i withObject:event];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:versionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	
    // Migrate from version 3 settings to version 4 settings
    if ([[NSUserDefaults standardUserDefaults] integerForKey:versionKey] < 4) {
        NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
        for (int i = 0; i < events.count; i++) {
            NSMutableDictionary *event = [events objectAtIndex:i];
            switch (i % 3) {
                case 0:
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.green] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.red] forKey:remainingColorKey];
                    break;
                case 1:
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.red] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.blue] forKey:remainingColorKey];
                    break;
                case 2:
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.blue] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.green] forKey:remainingColorKey];
                    break;
            }
            [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.white] forKey:backgroundColorKey];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:versionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

	// Observe the store
	self.appStore = [[AppStoreDelegate alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:transactionsKey]];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreTransactionShouldBeRecorded
													  object:self.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notif) {
													  [[NSUserDefaults standardUserDefaults] setObject:self.appStore.transactionStore 
																								forKey:transactionsKey];
													  [[NSUserDefaults standardUserDefaults] synchronize];
												  }];
    //disable to able to reuse identifier for other reasons
	//[self.appStore requestProductData:multipleEventsProductIdentifier ifHasTransaction:NO];

    // Add the main view controller's view to the window and display.

    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
    mainViewController = (MainViewController *)[rootNavigationController topViewController];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // get event index by name and display it
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self applicationDidEnterBackground:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // force every event to redraw/recalculate when next drawn
    for (EventViewController* event in self.mainViewController.events) {
        event.oldEvent = nil;
    }
}

#pragma mark - Crash reporter delegate

- (void)connectionOpened {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionClosed {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    for (EventViewController* event in self.mainViewController.events) {
        if (event.eventID != mainViewController.pager.currentPage) {
            [mainViewController.events replaceObjectAtIndex:event.eventID withObject:[NSNull null]];
        }
    }
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
