//
//  Doing_TimeAppDelegate.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <EventKit/EventKit.h>
#import "AppStoreDelegate.h"
#import "Constants.h"

@class MainViewController;

@interface Doing_TimeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainViewController;
	AppStoreDelegate *_appStore;
//	EKEventStore *_eventStore;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet MainViewController *mainViewController;
//@property (nonatomic, strong) IBOutlet EKEventStore *eventStore;

@property (nonatomic, strong) IBOutlet AppStoreDelegate *appStore;
@property BOOL allowInAppPurchases;
@property (readonly) UIColor *red;
@property (readonly) UIColor *blue;
@property (readonly) UIColor *green;
@property (readonly) UIColor *white;

@end

