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

@interface EventViewController (Private)

- (Boolean)eventEqualsOldEvent:(NSDictionary *)newEvent;

@end

@implementation EventViewController

@synthesize pieChart = _pieChart;
@synthesize daysComplete = _daysComplete;
@synthesize daysLeft = _daysLeft;
@synthesize dateRange;
@synthesize eventTitle = _eventTitle;
@synthesize eventID = _eventID;
@synthesize controls = _controls;
@synthesize piePlate = _piePlate;
@synthesize mainView = _mainView;

- (id)initWithEvent:(NSUInteger)event {
	if (self = [super initWithNibName:@"EventView" bundle:nil]) {
		self.eventID = event;
        self.oldEvent = nil;
        self.calendar = [NSCalendar currentCalendar];
	}
	return self;
}

- (void)redrawEvent:(BOOL)forceRedraw {
	forceRedraw = [self setPieChartValues:forceRedraw];
	if (forceRedraw) {
        // TODO: including all these works, but are probably overkill - need to only trigger the minimum needed changes
        [self.view setNeedsDisplay];
        [self.view setNeedsLayout];
        [self.mainView.scroller setNeedsDisplay];
        [self.mainView.scroller setNeedsLayout];
        [self.mainView.view setNeedsDisplay];
        [self.mainView.view setNeedsLayout];
	}
}

- (BOOL)setPieChartValues:(BOOL)forceRedraw {
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:1];
	if (self.eventID >= [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		return NO; // do not attempt to setup the piechart if the event ID is not in the array
	}
	NSInteger inFuture = 0;
	NSInteger inPast = 0;
	// BOOL isRealStart = NO;
	// startDate is used for computations, realStartDate is used for sane UI
	NSDictionary *event = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:self.eventID];
    BOOL showPercentage = [[event objectForKey:showPercentageKey] boolValue];
    BOOL showRemainingDaysOnly = [[event objectForKey:showCompletedDaysKey] boolValue];
    BOOL showTotals = [event[showTotalsKey] boolValue];
    BOOL showDateRange = [event[showEventDatesKey] boolValue];
    //NSDate *startDate = [self.calendar dateFromComponents:[self.calendar components:unitFlags fromDate:[event objectForKey:startKey]]];
    //NSDate *endDate = [self.calendar dateFromComponents:[self.calendar components:unitFlags fromDate:[event objectForKey:endKey]]];
    NSDate *startDate = [event objectForKey:startKey];
	NSDate *calcStartDate = startDate;
    NSDate *endDate = [event objectForKey:endKey];
    NSDate *calcEndDate = [self.calendar dateByAddingComponents:oneDay toDate:endDate options:0];
    if (event[includeLastDayInCalcKey]) {
        calcEndDate = [endDate dateByAddingTimeInterval:1.0];
    }
	NSDate *today = [self.calendar dateFromComponents:[self.calendar components:unitFlags fromDate:[NSDate date]]];
	NSLog(@"Start date:  %@", startDate);
	NSLog(@"End date:    %@", endDate);
	NSLog(@"Today:       %@", today);
	NSLog(@"Calc start:  %@", calcStartDate);
    NSLog(@"Calc end:    %@", calcEndDate);
	NSLog(@"Now:         %@", [NSDate date]);

    NSInteger completed = [[self.calendar components:NSDayCalendarUnit
                                                fromDate:calcStartDate
                                                  toDate:today
                                                 options:0]
						   day];
	NSInteger left = [[self.calendar components:NSDayCalendarUnit
                                           fromDate:today
                                             toDate:calcEndDate
                                            options:0]
					  day];
	NSInteger duration = [[self.calendar components:NSDayCalendarUnit
                                               fromDate:calcStartDate
                                                 toDate:calcEndDate
                                                options:0]
						  day];
	NSLog(@"%d days complete", completed);
	NSLog(@"%d days left", left);
	NSLog(@"%d total days", duration);
    if (!duration) {
        duration = 1;
        left++;
    }
    switch ([event[todayIsKey] integerValue]) {
        case todayIsNotCounted:
            completed--;
            break;
        case todayIsOver:
            completed++;
            break;
        case todayIsRemaining:
            if (![today isEqualToDate:[self.calendar dateFromComponents:[self.calendar components:unitFlags fromDate:calcEndDate]]]) {
                left++;
            }
            break;
        default:
            break;
    }
	if (completed <= 0) {
		inFuture = (completed * -1) + 1;
		completed = 0;
		left = duration;
	} else if (completed > duration) {
		inPast = left * -1;
		completed = duration;
		left = 0;
    }
    if (duration != (completed + left)) {
        if (duration == (completed + left + 1)) {
            completed++;
        } else {
            TFLog(@"Event (from %@ to %@) has duration (%d) != days complete (%d) + days left (%d)", startDate, endDate, duration, completed, left);
        }
    }
    NSLog(@"--after adjustments--");
	NSLog(@"%d days complete", completed);
	NSLog(@"%d days left", left);
	NSLog(@"%d total days", duration);
    NSLog(@"%d days in future", inFuture);
    NSLog(@"%d days in past", inPast);
	float interval = 1.0 / duration;
	
	_eventTitle.text = [event objectForKey:titleKey];
	
	[_pieChart clearItems];
	
	[_pieChart setGradientFillStart:0.3 andEnd:1.0];
	[_pieChart setGradientFillColor:PieChartItemColorMake(0.0, 0.0, 0.0, 0.7)];
	
	[_pieChart addItemValue:(interval * completed) withColor:PieChartItemColorMake(0.5, 1.0, 0.5, 0.8)]; // days completed
	[_pieChart addItemValue:(interval * left) withColor:PieChartItemColorMake(1.0, 0.5, 0.5, 0.8)]; // days left
	
	
	NSString *days = NSLocalizedString(@"days", @"Plural for \"day\"");
    NSLog((showTotals) ? @"Showing totals" : @"Hiding totals");
    NSLog((showPercentage) ? @"Showing percentage" : @"Hiding percentage");
    if (showPercentage || showTotals) {
        NSLog(@"Writing percentages or totals");
        _daysComplete.hidden = NO;
        _daysLeft.hidden = NO;
        if (!inFuture) {
            if (showRemainingDaysOnly) {
                if (completed == 1) {
                    days = NSLocalizedString(@"day", @"Singular form of \"day\"");
                }
                if (completed == 0) {
                    _daysComplete.hidden = YES;
                } else if (!showPercentage && showTotals) {
                    _daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ complete", @"The number (%d) of days (%@) complete"), completed, days];
                } else if (!showTotals && showPercentage) {
                    _daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%2.4g%% complete", @"The percentage of days complete"), interval * completed * 100];
                } else {
                    _daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) complete", @"The number (%d) of days (%@) complete with the percent of days past in parenthesis"), completed, days, interval * completed * 100];
                }
            } else {
                _daysComplete.hidden = YES;
            }
        } else if (showTotals) {
            if (inFuture == 1) {
                _daysComplete.text = NSLocalizedString(@"Begins tomorrow", @"The message displayed when the event will start tomorrow");
            } else {
                _daysComplete.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Begins in %d days", @"The message displayed when the event will start %d days in the future"),
                                      inFuture];
            }
        } else {
            _daysComplete.text = NSLocalizedString(@"Not yet begun", @"The message displayed when event will start in future, but totals are hidden");
        }
        if (!inPast) {
            if (left == 1) {
                days = NSLocalizedString(@"day", @"");
            } else {
                days = NSLocalizedString(@"days", @"");
            }
            if (left == 0) {
                _daysLeft.text = NSLocalizedString(@"Ends today", @"The message displayed on the last day of an event");
            } else if (!showPercentage && showTotals) {
                _daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ left", @"The number (%d) of days (%@) remaining"), left, days];
            } else if (!showTotals && showPercentage) {
                _daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%2.4g%% left", @"The percentage of days complete"), interval * left * 100];
            } else {
                _daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) left", @"The number (%d) of days (%@) remaining with the percentage remaining in parenthesis"), left, days, interval * left * 100];
            }
        } else if (showTotals) {
            if (inPast == 1) {
                _daysLeft.text = NSLocalizedString(@"Ended yesterday", @"Message displayed to indicate the event ended the day prior.");
            } else {
                _daysLeft.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Ended %d days ago", @"Message indicating the event ended some days in the past"),
                                  inPast];
            }
        } else {
            _daysLeft.text = NSLocalizedString(@"Ended", @"Message displayed when event is over, but totals are hidden");
        }
    } else {
        _daysComplete.hidden = YES;
        _daysLeft.hidden = YES;
    }
    self.dateRange.hidden = !showDateRange;
    if (showDateRange) {
        if (duration != 1) {
            dateRange.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ to %@", @"The range from start to end"),
                              [NSDateFormatter localizedStringFromDate:startDate
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterNoStyle],
                              [NSDateFormatter localizedStringFromDate:endDate
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterNoStyle]];
        } else {
            dateRange.text = [NSDateFormatter localizedStringFromDate:startDate
                                                            dateStyle:NSDateFormatterMediumStyle
                                                            timeStyle:NSDateFormatterNoStyle];
        }
    }
	forceRedraw = ([self eventEqualsOldEvent:event]) ? forceRedraw : YES;
    self.oldEvent = event;

	if ([self isViewLoaded] && forceRedraw) {
		_pieChart.alpha = 0.0;
		[_pieChart setHidden:NO];
		[_pieChart setNeedsDisplay];
        if (showTotals || showPercentage) {
            if (!self.daysComplete.hidden) {
                _daysComplete.alpha = 0.0;
                [_daysComplete setHidden:NO];
                [_daysComplete setNeedsDisplay];
            }
            _daysLeft.alpha = 0.0;
            [_daysLeft setHidden:NO];
            [_daysLeft setNeedsDisplay];
		}
        if (showDateRange) {
            dateRange.alpha = 0.0;
            [dateRange setHidden:NO];
            [dateRange setNeedsDisplay];
        }
		_eventTitle.alpha = 0.0;
		[_eventTitle setHidden:NO];
		[_eventTitle setNeedsDisplay];
		// Animate the fade-in
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		_pieChart.alpha = 1.0;
		_daysComplete.alpha = 1.0;
		_daysLeft.alpha = 1.0;
        dateRange.alpha = 1.0;
		_eventTitle.alpha = 1.0;
		[UIView commitAnimations];
	}
	return forceRedraw;
}

- (Boolean)eventEqualsOldEvent:(NSDictionary *)newEvent {
    for (NSString *key in self.oldEvent.allKeys) {
        if (![newEvent[key] isEqual:self.oldEvent[key]]) {
            return false;
        }
    }
    return true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setPieChartValues:YES];
}

- (IBAction)showInfo:(id)sender {
	[self.mainView showInfo:sender];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
