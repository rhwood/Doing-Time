//
//  MainViewController.h
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
#import <iAd/iAd.h>

@class Doing_TimeAppDelegate;

@interface MainViewController : UIViewController <ADBannerViewDelegate, UIScrollViewDelegate> {
	
	UIView *_controls;
//	EKEventStore *_eventStore;
	BOOL _bannerIsVisible;
	UIPageControl *_pager;
	UIScrollView *_scroller;
	NSMutableArray *_events;
	BOOL _pagerDidScroll;
	Doing_TimeAppDelegate *_appDelegate;
	ADBannerView *_adBanner;
	NSTimer *_dayOverTimer;
	
}

#pragma mark - Swipe handling

- (void)handleSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)showPager;
- (IBAction)changePage:(id)sender;

#pragma mark - Events handling

- (void)loadScrollerWithEvent:(NSUInteger)event;
- (void)redrawEvent:(NSInteger)event forceRedraw:(BOOL)forceRedraw;
- (void)redrawEvents:(BOOL)forceRedraw;
- (void)redrawEventsOnTimer:(NSTimer *)timer;
- (void)scheduleRedrawOnDayOver;
- (void)reloadEvents;
- (void)unloadEvents;

#pragma mark - Settings handling

- (IBAction)showInfo:(id)sender;
- (IBAction)showSettings:(id)sender;

#pragma mark - iAd Delegate

- (void)hideAdBanner:(BOOL)hide animated:(BOOL)animated;

@property (nonatomic, strong) IBOutlet UIView *controls;
//@property (nonatomic, strong) IBOutlet EKEventStore *eventStore;
@property (nonatomic, strong) IBOutlet UIPageControl *pager;
@property (nonatomic, strong) IBOutlet UIScrollView *scroller;
@property (nonatomic, strong) IBOutlet NSMutableArray *events;
@property (nonatomic, strong) IBOutlet UIButton *listButton;
@property (strong) IBOutlet UIButton *settingsButton;
@property BOOL bannerIsVisible;
@property BOOL pagerDidScroll;
@property (nonatomic, strong) Doing_TimeAppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet ADBannerView *adBanner;
@property (nonatomic, strong) NSTimer *dayOverTimer;

@property BOOL firstRun;

@end
