//
//  EventsListViewController.m
//  Doing Time
//
//  Created by Randall Wood on 6/12/2013.
//
//

#import "EventsListViewController.h"
#import "EventViewCell.h"
#import "EventViewController.h"
#import "Constants.h"
#import "NSDate+Additions.h"
#import "PieChartView.h"

@interface EventsListViewController ()

@end

@implementation EventsListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.calendar = [NSCalendar currentCalendar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.calendar == nil) {
        self.calendar = [NSCalendar currentCalendar];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Calling for %@", indexPath.debugDescription);
	EventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventViewCell"];
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    NSDictionary* event = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:indexPath.row];
    cell.stats.text = @"";

    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:1];
	NSInteger inFuture = 0;
	NSInteger inPast = 0;
    BOOL showPercentage = [event[showPercentageKey] boolValue];
    BOOL showCompleted = [event[showCompletedDaysKey] boolValue];
    BOOL showTotals = [event[showTotalsKey] boolValue];
    BOOL showDateRange = [event[showEventDatesKey] boolValue];
    UIColor *completedColor = [NSKeyedUnarchiver unarchiveObjectWithData:event[completedColorKey]];
    UIColor *remainingColor = [NSKeyedUnarchiver unarchiveObjectWithData:event[remainingColorKey]];
    cell.backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:event[backgroundColorKey]];
    NSDate *startDate = event[startKey];
    NSDate *endDate = event[endKey];
    NSLog(@"Calc end based on includeLastDayInCalcKey %@ and calendar %@", ([event[includeLastDayInCalcKey] boolValue]) ? @"YES" : @"NO", self.calendar);
    NSDate *calcEndDate = ([event[includeLastDayInCalcKey] boolValue]) ? [self.calendar dateByAddingComponents:oneDay toDate:endDate options:0] : endDate;
	NSDate *today = [NSDate midnightForDate:[NSDate date]];
	NSLog(@"Start date:  %@", startDate);
	NSLog(@"End date:    %@", endDate);
	NSLog(@"Today:       %@", today);
    NSLog(@"Calc end:    %@", calcEndDate);
	NSLog(@"Now:         %@", [NSDate date]);
    
    NSInteger completed = [[self.calendar components:NSDayCalendarUnit
                                            fromDate:startDate
                                              toDate:today
                                             options:0]
						   day];
	NSInteger left = [[self.calendar components:NSDayCalendarUnit
                                       fromDate:today
                                         toDate:calcEndDate
                                        options:0]
					  day];
	NSInteger duration = [[self.calendar components:NSDayCalendarUnit
                                           fromDate:startDate
                                             toDate:calcEndDate
                                            options:0]
						  day];
	NSLog(@"%d days complete", completed);
	NSLog(@"%d days left", left);
	NSLog(@"%d total days", duration);
    NSLog(@"--adjusting--");
    // only make adjustments for today if event is current
    if (left >= 0 && completed >= 0) {
        switch ([event[todayIsKey] integerValue]) {
            case todayIsNotCounted:
                NSLog(@"today is not counted (left --)");
                left--;
                break;
            case todayIsOver:
                NSLog(@"today is over (complete ++ & left --)");
                completed++;
                left--;
                break;
            case todayIsRemaining:
                // logical default case
                break;
            default:
                break;
        }
    }
    // event is over
    if (left <= 0) {
        NSLog(@"event is over");
        completed = duration;
        inPast = left * -1;
        left = 0;
        if ([endDate isEqualToDate:calcEndDate]) {
            NSLog(@"last day not in event");
            inPast++;
        }
    }
    // event has yet to begin
    if (completed < 0) {
        NSLog(@"event is in future");
        left = duration;
        inFuture = completed * -1;
        completed = 0;
    }
    // calculations have created too long an event
    if ((completed + left) > duration) {
        TFLog(@"Event (from %@ to %@) has duration (%d) != days complete (%d) + days left (%d)\n(today is %@, last day is counted %@)", startDate, endDate, duration, completed, left, event[todayIsKey], event[includeLastDayInCalcKey]);
    }
    NSLog(@"--after adjustments--");
	NSLog(@"%d days complete", completed);
	NSLog(@"%d days left", left);
	NSLog(@"%d total days", duration);
    NSLog(@"%d days in future", inFuture);
    NSLog(@"%d days in past", inPast);
	float interval = 1.0 / duration;
	
	cell.title.text = [event objectForKey:titleKey];
	
	[cell.pieChart clearItems];
	
	[cell.pieChart setGradientFillStart:0.0 andEnd:0.0];
	[cell.pieChart setGradientFillColor:PieChartItemColorMake(0.0, 0.0, 0.0, 0.7)];
	
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if (![completedColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"Something went wrong with the completed color");
    }
    NSLog(@"Interval: %f Completed: %i", interval, completed);
	[cell.pieChart addItemValue:(interval * completed) withColor:PieChartItemColorMake(red, green, blue, alpha)]; // days completed
    if (![remainingColor getRed:&red green:&green blue:&blue alpha:&alpha]) {
        NSLog(@"Something went wrong with the remaining color");
    }
    NSLog(@"Interval: %f Left: %i", interval, left);
	[cell.pieChart addItemValue:(interval * left) withColor:PieChartItemColorMake(red, green, blue, alpha)]; // days left
	
	
	NSString *days = NSLocalizedString(@"days", @"Plural for \"day\"");
    NSLog((showTotals) ? @"Showing totals" : @"Hiding totals");
    NSLog((showPercentage) ? @"Showing percentage" : @"Hiding percentage");
    if (showTotals && showPercentage) {
        showCompleted = NO; // set showCompleted off since both totals and percentages will not fit
    }
    if (showPercentage || showTotals) {
        NSLog(@"Unhiding stats");
        cell.stats.hidden = NO;
        if (inFuture) {
            // event has yet to begin
            if (showTotals) {
                // show # of days until event starts
                if (inFuture == 1) {
                    cell.stats.text = NSLocalizedString(@"Begins tomorrow", @"The message displayed when the event will start tomorrow");
                } else {
                    cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Begins in %d days", @"The message displayed when the event will start %d days in the future"),
                                       inFuture];
                }
            } else {
                // be vague
                cell.stats.text = NSLocalizedString(@"Not yet begun", @"The message displayed when event will start in future, but totals are hidden");
            }
        } else if (inPast) {
            // event has ended
            if (showTotals) {
                // show # of days since event ended
                if (inPast == 1) {
                    cell.stats.text = NSLocalizedString(@"Ended yesterday", @"Message displayed to indicate the event ended the day prior.");
                } else {
                    cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Ended %d days ago", @"Message indicating the event ended some days in the past"),
                                       inPast];
                }
            } else {
                // be vague
                cell.stats.text = NSLocalizedString(@"Ended", @"Message displayed when event is over, but totals are hidden");
            }
        } else {
            // event is ongoing
            if (showCompleted) {
                if (completed == 1) {
                    days = NSLocalizedString(@"day", @"Singular form of \"day\"");
                }
                if (completed == 0) {
                    cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Starting today", @"Message displayed when event starts to today, but today is not \"complete\"")];
                } else if (!showPercentage && showTotals) {
                    if (completed == 1 && !inPast) {
                        cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Started yesterday", @"Started yesterday, but no percentages displayed")];
                    } else {
                        cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ complete", @"The number (%d) of days (%@) complete"), completed, days];
                    }
                } else if (!showTotals && showPercentage) {
                    cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%2.4g%% complete", @"The percentage of days complete"), interval * completed * 100];
                } else {
                    if (completed == 1 && !inPast) {
                        cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Started yesterday (%2.4g%% complete)", @"Started yesterday, with percentage complete"), interval * completed * 100];
                    } else {
                        cell.stats.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) complete", @"The number (%d) of days (%@) complete with the percent of days past in parenthesis"), completed, days, interval * completed * 100];
                    }
                }
                cell.stats.text = [cell.stats.text stringByAppendingString:@"  |  "];
            }
            // reset plurality of days since the inFuture tests could have botched it for us
            if (left == 1) {
                days = NSLocalizedString(@"day", @"");
            } else {
                days = NSLocalizedString(@"days", @"");
            }
            if (left == 0) {
                cell.stats.text = [cell.stats.text stringByAppendingString:NSLocalizedString(@"Ends today", @"The message displayed on the last day of an event")];
            } else if (!showPercentage && showTotals) {
                cell.stats.text = [cell.stats.text stringByAppendingString:[NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ left", @"The number (%d) of days (%@) remaining"), left, days]];
            } else if (!showTotals && showPercentage) {
                cell.stats.text = [cell.stats.text stringByAppendingString:[NSString localizedStringWithFormat:NSLocalizedString(@"%2.4g%% left", @"The percentage of days complete"), interval * left * 100]];
            } else {
                cell.stats.text = [cell.stats.text stringByAppendingString:[NSString localizedStringWithFormat:NSLocalizedString(@"%d %@ (%2.4g%%) left", @"The number (%d) of days (%@) remaining with the percentage remaining in parenthesis"), left, days, interval * left * 100]];
            }
        }
        NSLog(@"Stats are: %@", cell.stats.text);
    } else {
        NSLog(@"Hiding stats");
        cell.stats.hidden = YES;
    }
    if (showDateRange && duration != 1) {
        cell.dates.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ to %@", @"The range from start to end"),
                           [NSDateFormatter localizedStringFromDate:startDate
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle],
                           [NSDateFormatter localizedStringFromDate:endDate
                                                          dateStyle:NSDateFormatterMediumStyle
                                                          timeStyle:NSDateFormatterNoStyle]];
        cell.dates.hidden = YES;
    } else {
        NSLog(@"Showing stats as dates");
        cell.dates.text = cell.stats.text;
        cell.dates.hidden = cell.stats.hidden;
        cell.stats.hidden = YES;
    }
    if ([EventViewController brightnessForColor:cell.backgroundColor] < 0.51) {
        cell.title.textColor = [UIColor whiteColor];
        cell.dates.textColor = [UIColor whiteColor];
        cell.stats.textColor = [UIColor whiteColor];
    } else {
        cell.title.textColor = [UIColor blackColor];
        cell.dates.textColor = [UIColor blackColor];
        cell.stats.textColor = [UIColor blackColor];
    }
	if ([self isViewLoaded]) {
		cell.pieChart.alpha = 0.0;
		cell.pieChart.hidden = NO;
		[cell.pieChart setNeedsDisplay];
        if ((showTotals || showPercentage) && showDateRange) {
            cell.stats.alpha = 0.0;
            cell.stats.hidden = NO;
            [cell.stats setNeedsDisplay];
		}
        if (showDateRange) {
            cell.dates.alpha = 0.0;
            cell.dates.hidden = NO;
            [cell.dates setNeedsDisplay];
        }
		cell.title.alpha = 0.0;
        cell.title.hidden = NO;
		[cell.title setNeedsDisplay];
		// Animate the fade-in
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		cell.pieChart.alpha = 1.0;
		cell.stats.alpha = 1.0;
        cell.dates.alpha = 1.0;
		cell.title.alpha = 1.0;
		[UIView commitAnimations];
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
		[events removeObjectAtIndex:indexPath.row];
		[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//		[delegate eventWasRemoved:indexPath.row];
	} else {
//		[self addEvent];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
	NSDictionary *event = [events objectAtIndex:sourceIndexPath.row];
	[events removeObjectAtIndex:sourceIndexPath.row];
	[events insertObject:event atIndex:destinationIndexPath.row];
	[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
//	[self.delegate eventDidMove:sourceIndexPath.row to:destinationIndexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
