//
//  MainViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "MainViewController.h"
#import "EventViewController.h"
#import "Doing_TimeAppDelegate.h"
#import "AppStoreDelegate.h"
#import "Constants.h"

@implementation MainViewController

@synthesize controls = _controls;
@synthesize bannerIsVisible = _bannerIsVisible;
@synthesize displayBanner = _displayBanner;
@synthesize pagerIsVisible = _pagerIsVisible;
@synthesize eventStore = _eventStore;
@synthesize pager = _pager;
@synthesize scroller = _scroller;
@synthesize events = _events;
@synthesize pagerDidScroll = _pagerDidScroll;
@synthesize appDelegate = _appDelegate;
@synthesize adBanner = _adBanner;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set Defaults
	self.pagerIsVisible = NO;
	self.displayBanner = YES;
	self.bannerIsVisible = NO;
	self.appDelegate = [UIApplication sharedApplication].delegate;
	self.eventStore = self.appDelegate.eventStore;

	// Display Defaults
	if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		self.displayBanner = NO;
		[self.adBanner removeFromSuperview];
	}
	self.pager.currentPage = [[NSUserDefaults standardUserDefaults] integerForKey:currentEventKey];

	// Recognize left/right swipes
	UISwipeGestureRecognizer *recognizer;
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];
	
	[self initEvents];
	
	// Register for Notifications
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreNewContentShouldBeProvided
													  object:self.appDelegate.appStoreDelegate
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  if ([[[notification userInfo] objectForKey:AXAppStoreProductIdentifier] isEqualToString:multipleEventsProductIdentifier]) {
														  self.displayBanner = NO;
														  self.adBanner.hidden = YES;
													  }
												  }];
}

- (void)viewDidAppear:(BOOL)animated {
	if (![self.events count]) {
		[self showInfo:nil];
	}
}

- (void)initEvents {
	// Initialize Events
	self.events = [NSMutableArray arrayWithCapacity:[[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]];
	if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		NSUInteger i;
		[self showPager];
		
		// fill array of eventviewcontrollers with placeholders
		for (i = 0; i < [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]; i++) {
			[self.events addObject:[NSNull null]];
		}
		
		// setup scroller here
		self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width * [self.events count], self.scroller.frame.size.height);

		self.pager.numberOfPages = [self.events count];
		
		[self loadScrollerWithEvent:self.pager.currentPage - 1];
		[self loadScrollerWithEvent:self.pager.currentPage];
		[self loadScrollerWithEvent:self.pager.currentPage + 1];
		
		[self changePage:nil];
	} else {
		[self.events addObject:[NSNull null]];
		[self loadScrollerWithEvent:0];
		self.pager.hidden = YES;
	}	
}

- (void)loadScrollerWithEvent:(NSUInteger)event {
	if (event < 0 || event >= [self.events count]) {
		return;
	}
	EventViewController *controller = [self.events objectAtIndex:event];
	if ((NSNull *)controller == [NSNull null]) {
		controller = [[EventViewController alloc] initWithEvent:event];
		controller.mainView = self;
		[self.events replaceObjectAtIndex:event withObject:controller];
		[controller release];
	}
	if (controller.view.superview == nil) {
		CGRect frame = self.scroller.frame;
		frame.origin.x = frame.size.width * event;
		frame.origin.y = 0;
		controller.view.frame = frame;
		[self.scroller addSubview:controller.view];
	}
}

- (void)redrawEvent:(NSInteger)event {
	if (event >= 0 && event < [self.events count]) {
		EventViewController *controller = [self.events objectAtIndex:event];
		if ((NSNull *)controller != [NSNull null]) {
			[controller setPieChartValues];
			[controller.pieChart setNeedsDisplay];
		}
	}
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
	if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		if (!self.pagerIsVisible) {
			self.controls.frame = CGRectOffset(self.controls.frame, 0, -self.controls.frame.size.height);
			self.scroller.frame = CGRectMake(0, 0, self.scroller.frame.size.width, self.scroller.frame.size.height - (self.controls.frame.size.height / 2));
			[self resizeEventsInScroller:self.controls.frame.size.height / -2];
		} else {
			self.controls.frame = CGRectOffset(self.controls.frame, 0, self.controls.frame.size.height);
			self.scroller.frame = CGRectMake(0, 0, self.scroller.frame.size.width, self.scroller.frame.size.height + (self.controls.frame.size.height / 2));
			[self resizeEventsInScroller:self.controls.frame.size.height / 2];
		}
		[UIView commitAnimations];
		self.pagerIsVisible = !self.pagerIsVisible;
	}
}

#pragma mark -
#pragma mark Flipside delegate

- (void)eventDidUpdate:(NSUInteger)eventIdentifier {
	if (eventIdentifier >= [self.events count]) {
		[self.events addObject:[NSNull null]];
		self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width * [self.events count], self.scroller.frame.size.height);
		self.pager.numberOfPages = [self.events count];
	} else {
		[self loadScrollerWithEvent:eventIdentifier];
	}
}

- (void)eventDidMove:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex {
	[self.events removeObjectAtIndex:sourceIndex];
	[self.events insertObject:[NSNull null] atIndex:destinationIndex];
	[self.events replaceObjectAtIndex:self.pager.currentPage withObject:[NSNull null]];
	[self loadScrollerWithEvent:self.pager.currentPage];
	if (self.pager.currentPage + 1 < [self.events count]) {
		[self.events replaceObjectAtIndex:self.pager.currentPage + 1 withObject:[NSNull null]];
		[self loadScrollerWithEvent:self.pager.currentPage + 1];
	}
	if (self.pager.currentPage - 1 >= 0) {
		[self.events replaceObjectAtIndex:self.pager.currentPage - 1 withObject:[NSNull null]];
		[self loadScrollerWithEvent:self.pager.currentPage - 1];
	}
	if (self.pager.currentPage + 2 < [self.events count]) {
		[self.events replaceObjectAtIndex:self.pager.currentPage + 2 withObject:[NSNull null]];
	}
	if (self.pager.currentPage - 2 >= 0) {
		[self.events replaceObjectAtIndex:self.pager.currentPage - 2 withObject:[NSNull null]];
	}
}

- (void)eventDisplayMethodUpdated {
	[self redrawEvent:self.pager.currentPage];
	[self redrawEvent:self.pager.currentPage + 1];
	[self redrawEvent:self.pager.currentPage - 1];
}

- (void)eventWasRemoved:(NSUInteger)eventIdentifier {
	if (eventIdentifier < [self.events count]) {
		[self.events removeObjectAtIndex:eventIdentifier];
		self.scroller.contentSize = CGSizeMake(self.scroller.frame.size.width * [self.events count], self.scroller.frame.size.height);
		self.pager.numberOfPages = [self.events count];
		if (self.pager.currentPage >= self.pager.numberOfPages) {
			self.pager.currentPage = 0;
			[self redrawEvent:self.pager.currentPage];
			[self redrawEvent:self.pager.currentPage + 1];
			[self redrawEvent:self.pager.currentPage - 1];
			[self changePage:nil];
		}	
	}
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
	[controller release];
}

- (IBAction)showInfo:(id)sender {
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
	//controller.navigationController = navigationController;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
	[controller release];
}

- (IBAction)changePage:(id)sender {
	NSInteger page = self.pager.currentPage;
	
	[self loadScrollerWithEvent:page - 1];
	[self loadScrollerWithEvent:page];
	[self loadScrollerWithEvent:page + 1];
	
	CGRect frame = self.scroller.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[self.scroller scrollRectToVisible:frame animated:YES];
	if (page - 2 >= 0) {
		[self.events replaceObjectAtIndex:page - 2 withObject:[NSNull null]];
	}
	if (page + 2 < [self.events count]) {
		[self.events replaceObjectAtIndex:page + 2 withObject:[NSNull null]];
	}
	
	self.pagerDidScroll = YES;
}

- (void)resizeEventsInScroller:(float)heightDifference {
	for (EventViewController *event in self.events) {
		if ((NSNull *)event != [NSNull null]) {
			event.piePlate.frame = CGRectMake(event.piePlate.frame.origin.x - (heightDifference /2),
											  event.piePlate.frame.origin.y,
											  event.piePlate.frame.size.width + heightDifference,
											  event.piePlate.frame.size.height);
		}
	}
}

#pragma mark -
#pragma mark Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.pagerDidScroll) {
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	self.pager.currentPage = page;
	
	[self loadScrollerWithEvent:page - 1];
	[self loadScrollerWithEvent:page];
	[self loadScrollerWithEvent:page + 1];
	}
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

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	// there is nothing to stop for this
	return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	if (self.displayBanner && !self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		// Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
		self.scroller.frame = CGRectMake(self.scroller.frame.origin.x,
										 self.scroller.frame.origin.y,
										 self.scroller.frame.size.width,
										 self.scroller.frame.size.height - banner.frame.size.height);
		[self resizeEventsInScroller:banner.frame.size.height * -1];
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error	{
	if (self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
		self.scroller.frame = CGRectMake(self.scroller.frame.origin.x,
										 self.scroller.frame.origin.y,
										 self.scroller.frame.size.width,
										 self.scroller.frame.size.height + banner.frame.size.height);
		[self resizeEventsInScroller:banner.frame.size.height];
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
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


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [super dealloc];
}


@end
