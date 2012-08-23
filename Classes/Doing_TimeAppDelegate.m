//
//  Doing_TimeAppDelegate.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "Doing_TimeAppDelegate.h"
#import "MainViewController.h"
#import "AppStoreDelegate.h"

@implementation Doing_TimeAppDelegate

@synthesize window;
@synthesize mainViewController;
@synthesize eventStore = _eventStore;
@synthesize appStore = _appStore;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [TestFlight takeOff:@"5aef4a4c9d323abe0561075aa2dc62f0_MTA2NjgyMDEyLTAzLTA2IDIwOjE1OjA5LjU0MDY0OQ"];

	//self.eventStore = [[EKEventStore alloc] init];
	
	// Migrate from version 1 settings to version 2 settings
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"Title"]) {
		NSMutableDictionary *activity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  [[NSUserDefaults standardUserDefaults] stringForKey:@"Title"],
								  titleKey,
								  [[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"],
								  startKey,
								  [[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"],
								  endKey,
								  nil];
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
	if (![[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]) {
		// 1 JAN 2001 17:00
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:61200] forKey:dayOverKey];
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
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
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
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
