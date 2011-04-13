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
	BOOL _displayBanner;
	BOOL _bannerIsVisible;
	BOOL _pagerIsVisible;
	UIPageControl *_pager;
	UIScrollView *_scroller;
	NSMutableArray *_events;
	BOOL _pagerDidScroll;
	Doing_TimeAppDelegate *_appDelegate;
	ADBannerView *_adBanner;
}

#pragma mark -
#pragma mark Swipe Handling

- (void)handleSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)showPager;
- (IBAction)changePage:(id)sender;

#pragma mark -
#pragma mark Events Handling

- (void)initEvents;
- (void)loadScrollerWithEvent:(NSUInteger)event;
- (void)redrawEvent:(NSInteger)event;
- (void)resizeEventsInScroller:(float)heightDifference;

#pragma mark -
#pragma mark Settings Handling

- (IBAction)showInfo:(id)sender;

@property (nonatomic, retain) IBOutlet UIView *controls;
@property (nonatomic, retain) IBOutlet EKEventStore *eventStore;
@property (nonatomic, retain) IBOutlet UIPageControl *pager;
@property (nonatomic, retain) IBOutlet UIScrollView *scroller;
@property (nonatomic, retain) IBOutlet NSMutableArray *events;
@property BOOL bannerIsVisible;
@property BOOL displayBanner;
@property BOOL pagerIsVisible;
@property BOOL pagerDidScroll;
@property (nonatomic, retain) Doing_TimeAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet ADBannerView *adBanner;

@end
