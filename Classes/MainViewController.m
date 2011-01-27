//
//  MainViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "MainViewController.h"
#import "PieChartView.h"

@implementation MainViewController

@synthesize pieChart = _pieChart;
@synthesize daysComplete = _daysComplete;
@synthesize daysLeft = _daysLeft;
@synthesize eventTitle = _eventTitle;
@synthesize controls = _controls;
@synthesize piePlate = _piePlate;
@synthesize bannerIsVisible = _bannerIsVisible;
@synthesize displayBanner = _displayBanner;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.displayBanner = YES; // place checks for ad-free licensing here
	self.bannerIsVisible = NO;

	if (![[NSUserDefaults standardUserDefaults] stringForKey:@"Title"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"Doing Time" forKey:@"Title"];
	}
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"] ||
		![[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"]) {
		NSDate *today = [NSDate midnightForDate:[NSDate date]];
		[[NSUserDefaults standardUserDefaults] setObject:today forKey:@"Start Date"];
		[[NSUserDefaults standardUserDefaults] setObject:today forKey:@"End Date"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self setPieChartValues];
	
	_pieChart.alpha = 0.0;
	[_pieChart setHidden:NO];
	[_pieChart setNeedsDisplay];
	
	_daysComplete.alpha = 0.0;
	[_daysComplete setHidden:NO];
	[_daysComplete setNeedsDisplay];
	
	_daysLeft.alpha = 0.0;
	[_daysLeft setHidden:NO];
	[_daysLeft setNeedsDisplay];
	
	_eventTitle.alpha = 0.0;
	[_eventTitle setHidden:NO];
	[_eventTitle setNeedsDisplay];
	
	// Animate the fade-in
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	_pieChart.alpha = 1.0;
	_daysComplete.alpha = 1.0;
	_daysLeft.alpha = 1.0;
	_eventTitle.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)setPieChartValues {
	NSDate *startDate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"]
						 dateByAddingTimeInterval:-86400.0];
	NSDate *endDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"];
	NSDate *today = [NSDate midnightForDate:[NSDate date]];
	if ([[NSTimeZone localTimeZone] secondsFromGMTForDate:today] != [[NSTimeZone localTimeZone] secondsFromGMTForDate:startDate]) {
		// get difference between timezones and adjust today
		NSLog(@"Humph.");
	}
	NSLog(@"Start date: %@", startDate);
	NSLog(@"End date:   %@", endDate);
	NSLog(@"Today:      %@", today);
	
	NSInteger completed = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
																	  fromDate:today 
																		toDate:[NSDate dateWithTimeInterval:[today timeIntervalSinceDate:startDate]
																								  sinceDate:today]
																	   options:0]
						   day];
	NSLog(@"%d days complete", completed);
	NSInteger left = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
																 fromDate:today 
																   toDate:[NSDate dateWithTimeInterval:[endDate timeIntervalSinceDate:today]
																							 sinceDate:today]
																  options:0]
					  day];
	NSLog(@"%d days left", left);
	NSInteger duration = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit
																  fromDate:startDate 
																	toDate:endDate
																   options:0]
						  day];
	NSLog(@"%d total days", duration);
	
	float interval = 1.0 / duration;
	
	_eventTitle.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Title"];
	
	[_pieChart clearItems];
	
	[_pieChart setGradientFillStart:0.3 andEnd:1.0];
	[_pieChart setGradientFillColor:PieChartItemColorMake(0.0, 0.0, 0.0, 0.7)];
	
	[_pieChart addItemValue:(interval * completed) withColor:PieChartItemColorMake(0.5, 1.0, 0.5, 0.8)]; // days completed
	[_pieChart addItemValue:(interval * left) withColor:PieChartItemColorMake(1.0, 0.5, 0.5, 0.8)]; // days left
	
	_daysComplete.text = [NSString localizedStringWithFormat:@"%d days completed", completed];
	_daysLeft.text = [NSString localizedStringWithFormat:@"%d days left", left];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self dismissModalViewControllerAnimated:YES];
	[self setPieChartValues];
	[_pieChart setNeedsDisplay];
}

- (IBAction)showInfo:(id)sender {
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	[controller release];
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
		self.controls.frame = CGRectOffset(self.controls.frame, 0, -banner.frame.size.height);
		self.piePlate.frame = CGRectOffset(self.piePlate.frame, 0, -banner.frame.size.height / 2);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error	{
	if (self.bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
		self.piePlate.frame = CGRectOffset(self.piePlate.frame, 0, banner.frame.size.height / 2);
		self.controls.frame = CGRectOffset(self.controls.frame, 0, banner.frame.size.height);
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
