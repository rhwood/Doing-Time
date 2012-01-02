//
//  Doing_TimeAppDelegate.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "Constants.h"
#import "CrashReportSender.h"

@class MainViewController;
@class AppStoreDelegate;

@interface Doing_TimeAppDelegate : NSObject <UIApplicationDelegate, CrashReportSenderDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
	AppStoreDelegate *_appStore;
	EKEventStore *_eventStore;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet EKEventStore *eventStore;
@property (nonatomic, retain) IBOutlet AppStoreDelegate *appStore;

@end

