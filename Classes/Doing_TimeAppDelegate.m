//
//  Doing_TimeAppDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//
//  Copyright 2010-2014, 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "Doing_TimeAppDelegate.h"
#import "MainViewController.h"
#import "EventViewController.h"

@implementation Doing_TimeAppDelegate

@synthesize window;
@synthesize mainViewController;

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
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.green requiringSecureCoding:true error:nil] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.red requiringSecureCoding:true error:nil] forKey:remainingColorKey];
                    break;
                case 1:
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.red requiringSecureCoding:true error:nil] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.blue requiringSecureCoding:true error:nil] forKey:remainingColorKey];
                    break;
                case 2:
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.blue requiringSecureCoding:true error:nil] forKey:completedColorKey];
                    [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.green requiringSecureCoding:true error:nil] forKey:remainingColorKey];
                    break;
            }
            [event setValue:[NSKeyedArchiver archivedDataWithRootObject:self.white requiringSecureCoding:true error:nil] forKey:backgroundColorKey];
        }
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:versionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // Add the main view controller's view to the window and display.

    self.window.backgroundColor = [UIColor clearColor];
    self.window.opaque = NO;
    UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
    mainViewController = (MainViewController *)[rootNavigationController topViewController];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
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
