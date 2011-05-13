//
//  EventViewController.m
//  Doing Time
//
//  Created by Randall Wood on 2/3/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "EventViewController.h"
#import "PieChartView.h"
#import "MainViewController.h"
#import "NSDate+Additions.h"
#import "Constants.h"

@implementation EventViewController

@synthesize pieChart = _pieChart;
@synthesize daysComplete = _daysComplete;
@synthesize daysLeft = _daysLeft;
@synthesize eventTitle = _eventTitle;
@synthesize eventID = _eventID;
@synthesize controls = _controls;
@synthesize piePlate = _piePlate;
@synthesize mainView = _mainView;
@synthesize oldComplete = _oldComplete;
@synthesize oldLeft = _oldLeft;
@synthesize oldTotal = _oldTotal;
@synthesize oldTitle = _oldTitle;

- (id)initWithEvent:(NSUInteger)event {
	if (self = [super initWithNibName:@"EventView" bundle:nil]) {
		self.eventID = event;
		self.oldTitle = @"";
		self.oldComplete = -1;
		self.oldLeft = -1;
		self.oldTotal = -1;
	}
	return self;
}

- (void)redrawEvent:(BOOL)forceRedraw {
	forceRedraw = [self setPieChartValues:forceRedraw];
	if (forceRedraw) {
		[self.pieChart setNeedsDisplay];
	}
}

- (BOOL)setPieChartValues:(BOOL)forceRedraw {
	if (self.eventID >= [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		return NO; // do not attempt to setup the piechart if the event ID is not in the array
	}
	NSInteger inFuture = 0;
	NSInteger inPast = 0;
	// BOOL isRealStart = NO;
	// startDate is used for computations, realStartDate is used for sane UI
	NSTimeInterval dayEnds = [[[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey] 
							  timeIntervalSinceReferenceDate] + [[NSTimeZone localTimeZone] secondsFromGMT];
	NSDictionary *event = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:self.eventID];
	NSDate *startDate = [[event objectForKey:startKey]
						 dateByAddingTimeInterval:-86400.0];
	// NSDate *realStartDate = [NSDate midnightForDate:[event objectForKey:startKey]];
	NSDate *endDate = [event objectForKey:endKey];
	NSDate *today = [NSDate midnightForDate:[NSDate date]];
//	NSLog(@"Since midnight for %@ is %f", today, [today timeIntervalSinceNow]);
	if (fabs(dayEnds) > fabs([today timeIntervalSinceNow])) {
		NSLog(@"Day is incomplete");
	}
//	NSLog(@"Seconds from GMT: %i", [[NSTimeZone localTimeZone] secondsFromGMT]);
	if ([[NSTimeZone localTimeZone] secondsFromGMTForDate:today] != [[NSTimeZone localTimeZone] secondsFromGMTForDate:startDate]) {
		// get difference between timezones and adjust today
		NSLog(@"Humph.");
	}
//	NSLog(@"Start date:  %@", startDate);
//	NSLog(@"Real Start:  %@", realStartDate);
//	NSLog(@"End date:    %@", endDate);
//	NSLog(@"Today:       %@", today);
//	NSLog(@"Reference    %@", [[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]);
//	NSLog(@"Now:         %@", [NSDate date]);
//	NSLog(@"Day ends at: %f", dayEnds);
	
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
	if (completed < 0) {
		inFuture = completed * -1;
		completed = 0;
		left = duration;
	} else if (completed > duration) {
		inPast = left * -1;
		completed = duration;
		left = 0;
	} else if (fabs(dayEnds) > fabs([today timeIntervalSinceNow])) {
		completed--;
		left++;
		if (completed < 0) {
			inFuture = completed * -1;
			completed = 0;
			left = duration;
		}
	}
	float interval = 1.0 / duration;
	
	_eventTitle.text = [event objectForKey:titleKey];
	
	[_pieChart clearItems];
	
	[_pieChart setGradientFillStart:0.3 andEnd:1.0];
	[_pieChart setGradientFillColor:PieChartItemColorMake(0.0, 0.0, 0.0, 0.7)];
	
	[_pieChart addItemValue:(interval * completed) withColor:PieChartItemColorMake(0.5, 1.0, 0.5, 0.8)]; // days completed
	[_pieChart addItemValue:(interval * left) withColor:PieChartItemColorMake(1.0, 0.5, 0.5, 0.8)]; // days left
	
	
	NSString *days = NSLocalizedString(@"days", @"Plural for \"day\"");
	if (!inFuture) {
		if (completed == 1) {
			days = NSLocalizedString(@"day", @"Singular form of \"day\"");
		}
		if (completed == 0) {
			_daysComplete.text = nil;
		} else if (![[NSUserDefaults standardUserDefaults] boolForKey:showPercentageKey]) {
			_daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ complete", @"The number (%d) of days (%@) complete"), completed, days];
		} else {
			_daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) complete", @"The number (%d) of days (%@) complete with the percent of days past in parenthesis"), completed, days, interval * completed * 100];
		}		
	} else {
		if (inFuture == 1) {
			_daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ begins tomorrow", @"The message displayed when the event (%@ is the event title) will start tomorrow"),
								  [event objectForKey:titleKey]];
		} else {
			_daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ begins in %d days", @"The message displayed when the event will start %d days in the future"),
								  [event objectForKey:titleKey],
								  inFuture];
		}
	}
	if (!inPast) {
		if (left == 1) {
			days = NSLocalizedString(@"day", @"");
		} else {
			days = NSLocalizedString(@"days", @"");
		}
		if (left == 0) {
			_daysLeft.text = nil;
		} else if (![[NSUserDefaults standardUserDefaults] boolForKey:showPercentageKey]) { 
			_daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ left", @"The number (%d) of days (%@) remaining"), left, days];
		} else {
			_daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) left", @"The number (%d) of days (%@) remaining with the percentage remaining in parenthesis"), left, days, interval * left * 100];
		}
	} else {
		if (inPast == 1) {
			_daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ ended yesterday", @"Message displayed to indicate the event ended the day prior."),
							  [event objectForKey:titleKey]];
		} else {
			_daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ ended %d days ago", @"Message indicating the event ended some days in the past"),
							  [event objectForKey:titleKey],
							  inPast];
		}
	}
	
	forceRedraw = (completed == self.oldComplete) ? forceRedraw : YES;
	forceRedraw = (left == self.oldLeft) ? forceRedraw : YES;
	forceRedraw = (duration == self.oldTotal) ? forceRedraw : YES;
	forceRedraw = ([self.oldTitle isEqualToString:_eventTitle.text]) ? forceRedraw : YES;
	self.oldComplete = completed;
	self.oldLeft = left;
	self.oldTotal = duration;
	self.oldTitle = _eventTitle.text;

	if ([self isViewLoaded] && forceRedraw) {
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
	return forceRedraw;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setPieChartValues:YES];
}

- (IBAction)showInfo:(id)sender {
	[self.mainView showInfo:sender];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
