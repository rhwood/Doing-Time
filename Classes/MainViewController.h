//
//  MainViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//
//  Copyright (c) 2010-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
