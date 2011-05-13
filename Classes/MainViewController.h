//
//  MainViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import <iAd/iAd.h>
#import <EventKit/EventKit.h>

@interface MainViewController : UIViewController <UIApplicationDelegate, FlipsideViewControllerDelegate, ADBannerViewDelegate, UIScrollViewDelegate> {
	
	UIView *_controls;
	EKEventStore *_eventStore;
	BOOL _bannerIsVisible;
	UIPageControl *_pager;
	UIScrollView *_scroller;
	NSMutableArray *_events;
	BOOL _pagerDidScroll;
	Doing_TimeAppDelegate *_appDelegate;
	ADBannerView *_adBanner;
	NSTimer *_dayOverTimer;
	
}

#pragma mark -
#pragma mark Swipe Handling

- (void)handleSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)showPager;
- (IBAction)changePage:(id)sender;

#pragma mark -
#pragma mark Events Handling

- (void)loadScrollerWithEvent:(NSUInteger)event;
- (void)redrawEvent:(NSInteger)event forceRedraw:(BOOL)forceRedraw;
- (void)redrawEvents:(BOOL)forceRedraw;
- (void)redrawEventsOnTimer:(NSTimer *)timer;
- (void)resizeEventsInScroller:(float)heightDifference;
- (void)scheduleRedrawOnDayOver;

#pragma mark -
#pragma mark Settings Handling

- (IBAction)showInfo:(id)sender;

#pragma mark -
#pragma mark iAd Delegate

- (void)hideAdBanner:(BOOL)hide animated:(BOOL)animated;

@property (nonatomic, retain) IBOutlet UIView *controls;
@property (nonatomic, retain) IBOutlet EKEventStore *eventStore;
@property (nonatomic, retain) IBOutlet UIPageControl *pager;
@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet NSMutableArray *events;
@property BOOL bannerIsVisible;
@property BOOL pagerDidScroll;
@property (nonatomic, retain) Doing_TimeAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet ADBannerView *adBanner;
@property (nonatomic, retain) NSTimer *dayOverTimer;

@end
