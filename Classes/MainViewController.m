//
//  MainViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "MainViewController.h"
#import "EventViewController.h"
#import "EventSettingsViewController.h"
#import "Doing_TimeAppDelegate.h"
#import "AppStoreDelegate.h"
#import "Constants.h"

@interface MainViewController (Private)

- (void)redrawBackground;

@end

@implementation MainViewController

@synthesize controls = _controls;
@synthesize bannerIsVisible = _bannerIsVisible;
//@synthesize eventStore = _eventStore;
@synthesize pager = _pager;
@synthesize scroller = _scroller;
@synthesize events = _events;
@synthesize pagerDidScroll = _pagerDidScroll;
@synthesize appDelegate = _appDelegate;
@synthesize adBanner = _adBanner;
@synthesize dayOverTimer = _dayOverTimer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set Defaults
	self.bannerIsVisible = NO;
	self.appDelegate = (Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate;
//	self.eventStore = self.appDelegate.eventStore;

	// Display Defaults
	if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
		self.pager.numberOfPages = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
		self.pager.currentPage = [[NSUserDefaults standardUserDefaults] integerForKey:currentEventKey];
		[self.adBanner removeFromSuperview];
	} else {
		self.pager.numberOfPages = 1;
		self.pager.currentPage = 0;
        self.controls.hidden = YES;
        self.bannerIsVisible = YES;
        [self hideAdBanner:YES animated:NO];
	}

	// Recognize left/right swipes
	UISwipeGestureRecognizer *recognizer;
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:recognizer];
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
	
	// Initialize Events
	self.events = [NSMutableArray arrayWithCapacity:self.pager.numberOfPages];
	[self showPager];
	
	// fill array of eventviewcontrollers with placeholders
	for (NSUInteger i = 0; i < self.pager.numberOfPages; i++) {
		[self loadScrollerWithEvent:i];
	}
	
	[self changePage:nil];
	
	// Register for Notifications
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreNewContentShouldBeProvided
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  if ([[[notification userInfo] objectForKey:AXAppStoreProductIdentifier] isEqualToString:multipleEventsProductIdentifier]) {
														  [self hideAdBanner:YES animated:NO];
														  [self.adBanner removeFromSuperview];
														  [self showPager];
													  }
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
													  object:[UIApplication sharedApplication]
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self reloadEvents];
													  [self scheduleRedrawOnDayOver];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
													  object:[UIApplication sharedApplication]
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  if (self.dayOverTimer) {
														  [self.dayOverTimer invalidate];
														  self.dayOverTimer = nil;
													  }
                                                      [self unloadEvents];
                                                  }];
	[self scheduleRedrawOnDayOver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawBackground];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey].count) {
        // Set reasonable defaults for the first event here
        if (![[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]) {
            NSDate *today = [NSDate midnightForDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:@[@{
                                                    titleKey:NSLocalizedString(@"Doing Time", @"Application Name"),
                                                    startKey:today,
                                                      endKey:today,
                                        showCompletedDaysKey:@(YES),
                                           showPercentageKey:@(NO),
                                                  todayIsKey:@(todayIsNotCounted)}]
                                                      forKey:eventsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome to Doing Time", @"Title for intro alert")
                                                        message:NSLocalizedString(@"Doing Time shows the progress towards completing a multi-day event.\n\nLet's configure our first event now.", @"Label for intro alert.")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Label indicating the user acknowledges the issue")
                                              otherButtonTitles:nil];
        [alert show];
        [self showInfo:self.events[0]];
    }
    [self redrawBackground];
}

- (void)loadScrollerWithEvent:(NSUInteger)event {
	EventViewController *controller;
	if (event > [self.events count]) {
		return;
	} else if (event == [self.events count]) {
		controller = [[EventViewController alloc] initWithEvent:event];
		controller.mainView = self;
		[self.events addObject:controller];
		self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width * [self.events count], self.scroller.frame.size.height);
	} else {
		controller = [self.events objectAtIndex:event];
        [controller redrawEvent:YES];
	}
	if (controller.view.superview == nil) {
		CGRect frame = self.scroller.frame;
		frame.origin.x = frame.size.width * event;
		frame.origin.y = 0;
		controller.view.frame = frame;
		[self.scroller addSubview:controller.view];
	}
}

- (void)redrawEvent:(NSInteger)event forceRedraw:(BOOL)forceRedraw {
	if (event >= 0 && event < [self.events count]) {
		EventViewController *controller = [self.events objectAtIndex:event];
		[controller redrawEvent:forceRedraw];
        [self redrawBackground];
	}
}

- (void)redrawEvents:(BOOL)forceRedraw {
	for (EventViewController *controller in self.events) {
		controller.eventID = [self.events indexOfObject:controller];
		[controller redrawEvent:forceRedraw];
	}
}

- (void)redrawEventsOnTimer:(NSTimer *)timer {
	[self redrawEvents:NO];
	[self scheduleRedrawOnDayOver];
}

- (void)scheduleRedrawOnDayOver {
	NSDate* dayOver = [[NSDate UTCMidnightForDate:[NSDate date]] dateByAddingTimeInterval:1.0];
	if (self.dayOverTimer) {
		if ([[self.dayOverTimer fireDate] isEqualToDate:dayOver]) {
			return;
		} else if ([self.dayOverTimer isValid]) {
			[self.dayOverTimer setFireDate:dayOver];
			return;
		} else {
			[self.dayOverTimer invalidate];
			self.dayOverTimer = nil;
		}
	}
	self.dayOverTimer = [[NSTimer alloc] initWithFireDate:dayOver
												 interval:0
												   target:self
												 selector:@selector(redrawEventsOnTimer:)
												 userInfo:nil
												  repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:self.dayOverTimer forMode:NSRunLoopCommonModes];
}

- (void)unloadEvents {
    NSLog(@"Unloading events");
    for (UIView *view in [self.scroller subviews]) {
        [view removeFromSuperview];   
    }
}

- (void)reloadEvents {
    NSLog(@"Reloading events");
    for (NSUInteger i = 0; i < self.pager.numberOfPages; i++) {
		[self loadScrollerWithEvent:i];
        NSLog(@"Reloaded event #%i", i);
	}
    [self changePage:nil];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		if (self.pager.currentPage < [self.events count] - 1) {
			self.pager.currentPage = self.pager.currentPage + 1;
			[self changePage:nil];
		}
	} else {
		if (self.pager.currentPage) {
			self.pager.currentPage = self.pager.currentPage - 1;
			[self changePage:nil];
		}
	}
	[[NSUserDefaults standardUserDefaults] setInteger:self.pager.currentPage forKey:currentEventKey];
}

- (void)showPager {
	if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		self.pager.superview.hidden = NO;
		[UIView commitAnimations];
	}
}

- (void)showList:(id)sender {
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    //controller.navigationController = navigationController;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navigationController animated:YES completion:nil];
    if ([sender respondsToSelector:@selector(eventID)]) {
        [controller editEvent:[sender eventID]];
    }
}

- (void)redrawBackground {
    self.view.backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:((EventViewController *)self.events[self.pager.currentPage]).event[backgroundColorKey]];
    if (((EventViewController *)self.events[self.pager.currentPage]).backgroundBrightness < .51) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.pager.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pager.currentPageIndicatorTintColor = [UIColor whiteColor];
        [self.listButton.imageView setImage:[UIImage imageNamed:@"white-list"]];
        [((EventViewController *)self.events[self.pager.currentPage]).settings.imageView setImage:[UIImage imageNamed:@"white-gear"]];
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        self.pager.pageIndicatorTintColor = [UIColor darkGrayColor];
        self.pager.currentPageIndicatorTintColor = [UIColor blackColor];
        [self.listButton.imageView setImage:[UIImage imageNamed:@"gray-list"]];
        [((EventViewController *)self.events[self.pager.currentPage]).settings.imageView setImage:[UIImage imageNamed:@"gray-gear"]];
    }
}

#pragma mark -
#pragma mark Flipside delegate

- (void)dayOverTimeUpdated {
	[self redrawEventsOnTimer:nil];
}

- (void)eventDidUpdate:(NSUInteger)eventIdentifier {
	if (eventIdentifier == [self.events count]) {
		[self loadScrollerWithEvent:eventIdentifier];
		self.pager.numberOfPages = [self.events count];
	} else {
		[self redrawEvent:eventIdentifier forceRedraw:YES];
	}
}

- (void)eventDidMove:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex {
	[self redrawEvents:NO];
}

- (void)eventDisplayMethodUpdated {
	[self redrawEvents:YES];
}

- (void)eventWasRemoved:(NSUInteger)eventIdentifier {
	if (eventIdentifier < [self.events count]) {
		[self.events removeObjectAtIndex:eventIdentifier];
		self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width * [self.events count], self.scroller.frame.size.height);
		self.pager.numberOfPages = [self.events count];
		[self redrawEvents:NO];
		if (self.pager.currentPage >= self.pager.numberOfPages) {
			self.pager.currentPage = 0;
			[self changePage:nil];
		}
	}
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender {
    EventSettingsViewController *controller = [[EventSettingsViewController alloc] initWithEventIndex:self.pager.currentPage];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    //controller.navigationController = navigationController;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)changePage:(id)sender {
	NSInteger page = self.pager.currentPage;
	
	CGRect frame = self.scroller.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[self.scroller scrollRectToVisible:frame animated:YES];
	
	self.pagerDidScroll = YES;
    [self redrawBackground];
}

#pragma mark -
#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.pagerDidScroll) {
		CGFloat pageWidth = scrollView.frame.size.width;
		int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pager.currentPage = page;
	}
	[self.pager updateCurrentPageDisplay];
    [self redrawBackground];
	[[NSUserDefaults standardUserDefaults] setInteger:self.pager.currentPage forKey:currentEventKey];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self.pagerDidScroll = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.pagerDidScroll = NO;
}

#pragma mark -
#pragma mark iAd delegate

- (void)hideAdBanner:(BOOL)hide animated:(BOOL)animated {
	if (hide != self.bannerIsVisible) {
		return;
	}
	if (animated) {
		[UIView beginAnimations:@"animateAdBanner" context:NULL];
	}
    self.bannerIsVisible = !hide;
    self.adBanner.hidden = hide;
	if (animated) {
		[UIView commitAnimations];
	}
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	// there is nothing to stop for this
	return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	if ([self.adBanner superview] && !self.bannerIsVisible) {
		[self hideAdBanner:NO animated:YES];
    }	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error	{
	if ([self.adBanner superview] && self.bannerIsVisible) {
		[self hideAdBanner:YES animated:YES];
    }	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

@end
