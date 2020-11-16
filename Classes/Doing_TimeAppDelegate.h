//
//  Doing_TimeAppDelegate.h
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
@property (readonly) UIColor *red;
@property (readonly) UIColor *blue;
@property (readonly) UIColor *green;
@property (readonly) UIColor *white;

@end

