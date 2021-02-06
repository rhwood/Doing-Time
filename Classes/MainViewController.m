//
//  MainViewController.m
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

#import "MainViewController.h"
#import "EventViewController.h"
#import "EventSettingsViewController.h"
#import "SettingsViewController.h"
#import "Doing_TimeAppDelegate.h"
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
@synthesize dayOverTimer = _dayOverTimer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
	// Set Defaults
	self.bannerIsVisible = NO;
	self.appDelegate = (Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate;
    //	self.eventStore = self.appDelegate.eventStore;
    
    // Initial Event
    if (![[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey].count) {
        // Set reasonable defaults for the first event here
        if (![[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]) {
            NSDate *today = [NSDate midnightForDate:[NSDate date]];
            [[NSUserDefaults standardUserDefaults] setObject:@[@{
                                                                   titleKey:NSLocalizedString(@"Doing Time", @"Application Name"),
                                                                   startKey:[today dateByAddingTimeInterval:60 * 60 * 24 * -60],
                                                                   endKey:[today dateByAddingTimeInterval:60 * 60 * 24 * 30],
                                                                   includeLastDayInCalcKey:@(YES),
                                                                   showCompletedDaysKey:@(NO),
                                                                   showEventDatesKey:@(NO),
                                                                   showPercentageKey:@(NO),
                                                                   showTotalsKey:@(NO),
                                                                   todayIsKey:@(todayIsNotCounted),
                                                                   completedColorKey:[NSKeyedArchiver archivedDataWithRootObject:self.appDelegate.green requiringSecureCoding:YES error:nil],
                                                                   remainingColorKey:[NSKeyedArchiver archivedDataWithRootObject:self.appDelegate.red requiringSecureCoding:YES error:nil],
                                                                   backgroundColorKey:[NSKeyedArchiver archivedDataWithRootObject:self.appDelegate.white requiringSecureCoding:YES error:nil]}]
                                                      forKey:eventsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.firstRun = YES;
    } else {
        self.firstRun = NO;
    }
    
	// Display Defaults
    self.pager.numberOfPages = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
    self.pager.currentPage = [[NSUserDefaults standardUserDefaults] integerForKey:currentEventKey];
    
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
    [[NSNotificationCenter defaultCenter] addObserverForName:selectedEventChanged
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self changePage:note];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:eventMovedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self eventDidMove:[note.userInfo[startKey] integerValue] to:[note.userInfo[endKey] integerValue]];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:eventRemovedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self eventWasRemoved:[[note.userInfo objectForKey:eventsKey] integerValue]];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:eventSavedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self eventDidUpdate:[[note.userInfo objectForKey:eventsKey] integerValue]];
                                                  }];
	[self scheduleRedrawOnDayOver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self redrawBackground];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self redrawBackground];
    if (self.firstRun) {
        self.firstRun = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome to Doing Time", @"Title for intro alert")
                                                        message:NSLocalizedString(@"Doing Time shows the progress towards completing a multi-day event.\n\nLet's configure our first event now.", @"Label for intro alert.")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Label indicating the user acknowledges the issue")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"EventsListSegue"]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    if ([segue.identifier isEqualToString:@"MainToEventSettingsSegue"]) {
        ((EventSettingsViewController *)segue.destinationViewController).index = self.pager.currentPage;
    }
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
        NSLog(@"Reloaded event #%lu", (unsigned long)i);
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
    [UIView beginAnimations:@"animateDisplayPager" context:NULL];
    self.pager.superview.hidden = NO;
    [UIView commitAnimations];
}

- (IBAction)showInfo:(id)sender {
    [self performSegueWithIdentifier:@"MainToEventSettingsSegue" sender:sender];
}

- (IBAction)showSettings:(id)sender {
    [self performSegueWithIdentifier:@"AppSettingsSegue" sender:sender];
}

- (void)redrawBackground {
    self.view.backgroundColor = [NSKeyedUnarchiver unarchivedObjectOfClass:UIColor.class fromData:((EventViewController *)self.events[self.pager.currentPage]).event[backgroundColorKey] error: nil];
    if (((EventViewController *)self.events[self.pager.currentPage]).backgroundBrightness < .51) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.pager.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pager.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.settingsButton.imageView.image = [UIImage imageNamed:@"white-info"];
        self.listButton.imageView.image = [UIImage imageNamed:@"white-list"];
        [((EventViewController *)self.events[self.pager.currentPage]).settings.imageView setImage:[UIImage imageNamed:@"white-info"]];
        [((EventViewController *)self.events[self.pager.currentPage]).infoButton.imageView setImage:[UIImage imageNamed:@"white-gear"]]; // gear
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        self.pager.pageIndicatorTintColor = [UIColor darkGrayColor];
        self.pager.currentPageIndicatorTintColor = [UIColor blackColor];
        self.settingsButton.imageView.image = [UIImage imageNamed:@"gray-info"];
        self.listButton.imageView.image = [UIImage imageNamed:@"gray-list"];
        [((EventViewController *)self.events[self.pager.currentPage]).settings.imageView setImage:[UIImage imageNamed:@"gray-info"]];
        [((EventViewController *)self.events[self.pager.currentPage]).infoButton.imageView setImage:[UIImage imageNamed:@"gray-gear"]]; // gear
    }
}

#pragma mark - Flipside delegate

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
		self.pager.numberOfPages = [self.events count];
		if (self.pager.currentPage >= self.pager.numberOfPages) {
			self.pager.currentPage = 0;
			[self changePage:nil];
		}
        [self unloadEvents];
        [self reloadEvents];
		[self redrawEvents:NO];
	}
}

- (IBAction)changePage:(id)sender {
    float duration = 0.2;
    if ([sender isKindOfClass:[NSNotification class]]) {
        duration = 0.0;
        self.pager.currentPage = [[((NSNotification *)sender).userInfo objectForKey:eventsKey] integerValue];
    }
	NSInteger page = self.pager.currentPage;
	
	CGRect frame = self.scroller.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
    [UIView animateWithDuration:duration animations:^{
        [self.scroller scrollRectToVisible:frame animated:NO];
        [self redrawBackground];
    }];
	
	self.pagerDidScroll = YES;
}

#pragma mark - Scroll view delegate

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

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:eventsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showInfo:nil];
}

@end
