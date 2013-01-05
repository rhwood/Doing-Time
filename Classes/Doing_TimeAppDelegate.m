//
//  Doing_TimeAppDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "Doing_TimeAppDelegate.h"
#import "MainViewController.h"
#import "EventViewController.h"
#import "AppStoreDelegate.h"

@implementation Doing_TimeAppDelegate

@synthesize window;
@synthesize mainViewController;
//@synthesize eventStore = _eventStore;
@synthesize appStore = _appStore;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [TestFlight takeOff:@"8224ac7b-0bfa-4396-b5bc-3b2404fbc9f0"];

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
	}
	[[NSUserDefaults standardUserDefaults] synchronize];

	// Set reasonable defaults for the first event here

	if (![[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]) {
		NSDate *today = [NSDate midnightForDate:[NSDate date]];
		[[NSUserDefaults standardUserDefaults] setObject:@[@{titleKey: NSLocalizedString(@"Doing Time", @"Application Name"),
																				   startKey: today,
																				   endKey: today}]
												  forKey:eventsKey];
		
	}
    // set showCompletedDaysKey to v1.2 behavior if the key does not exist
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:showCompletedDaysKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:showCompletedDaysKey];
    }
	if ([[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:dayOverKey];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];	
	
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
	[self.appStore requestProductData:multipleEventsProductIdentifier ifHasTransaction:NO];

    // Add the main view controller's view to the window and display.

    [window addSubview:mainViewController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [self applicationDidEnterBackground:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // force every event to redraw/recalculate when next drawn
    for (EventViewController* event in self.mainViewController.events) {
        event.oldTotal = -1;
    }
}

#pragma mark -
#pragma mark Crash reporter delegate

- (void)connectionOpened {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionClosed {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark Memory management

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
