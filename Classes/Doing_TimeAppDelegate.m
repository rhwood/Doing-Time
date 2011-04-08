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
@synthesize appStoreDelegate = _appStoreDelegate;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.  
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
		NSArray *activities = [NSArray arrayWithObject:activity];
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
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
																				   @"Doing Time",
																				   titleKey,
																				   today,
																				   startKey,
																				   today,
																				   endKey,
																				   nil]]
												  forKey:eventsKey];
		
	}
	if (![[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]) {
		// 1 JAN 2001 17:00
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceReferenceDate:61200] forKey:dayOverKey];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];	
	
	// Observe the store
	self.appStoreDelegate = [[AppStoreDelegate alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:transactionsKey]];
	if (![self.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreTransactionShouldBeRecorded
														  object:self.appStoreDelegate
														   queue:nil
													  usingBlock:^(NSNotification *notif) {
														  [[NSUserDefaults standardUserDefaults] setObject:self.appStoreDelegate.transactionStore 
																									forKey:transactionsKey];
														  [[NSUserDefaults standardUserDefaults] synchronize];
													  }];
		[self.appStoreDelegate requestProductData:multipleEventsProductIdentifier];
	}

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
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.appStoreDelegate release];
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
