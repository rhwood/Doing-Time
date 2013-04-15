//
//  EventSettingsViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "EventSettingsViewController.h"
#import "TodaySettingsViewController.h"
#import "MainViewController.h"
#import "Doing_TimeAppDelegate.h"
#import "Constants.h"

// Table Event section
#define EVENT 0
#define TITLE 0
#define START_DATE 1
#define END_DATE 2
#define DURATION 3
// Table Dates section
#define DATES 1
#define INCLUDE_END 0
#define TODAY_IS 1
#define CALENDAR 2
// Table Stats section
#define DISPLAY 2
#define SHOW_DATES 0
#define SHOW_PERCENTS 1
#define SHOW_TOTALS 2
#define SHOW_COMPLETE 3

@implementation EventSettingsViewController

@synthesize index = _index;
@synthesize event = _event;
@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize settingStartDate;
@synthesize settingEndDate;
@synthesize showErrorAlert;
@synthesize newEvent;
//@synthesize eventStore = _eventStore;
@synthesize startDateViewCellIndexPath = _startDateViewCellIndexPath;
@synthesize endDateViewCellIndexPath = _endDateViewCellIndexPath;
@synthesize detailTextLabelColor = _detailTextLabelColor;
@synthesize linkUnlinkedEventActionSheet = _linkUnlinkedEventActionSheet;
@synthesize changeLinkedEventActionSheet = _changeLinkedEventActionSheet;
@synthesize titleView = _titleView;
@synthesize titleViewCell = _titleViewCell;
@synthesize cancelling;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithEventIndex:(NSUInteger)index {
	if ((self = [super initWithNibName:@"EventSettingsView" bundle:nil])) {
        self.calendar = [NSCalendar currentCalendar];
		self.index = index;
		if (self.index == [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
			self.newEvent = YES;
            self.event = [NSMutableDictionary dictionaryWithDictionary:@{
                                                              titleKey:@"",
                                                              startKey:[NSDate distantPast],
                                                                endKey:[NSDate distantFuture],
                                               includeLastDayInCalcKey:@(YES),
                                                            todayIsKey:@(todayIsNotCounted),
                                                     showEventDatesKey:@(YES),
                                                     showPercentageKey:@(YES),
                                                  showCompletedDaysKey:@(NO),
                                                         showTotalsKey:@(YES)}];
		} else {
			self.event = [NSMutableDictionary dictionaryWithDictionary:[[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:index]];
			self.newEvent = NO;
            BOOL save = NO;
            if (![[self.event allKeys] containsObject:includeLastDayInCalcKey]) {
                [self.event setValue:@(YES) forKey:includeLastDayInCalcKey];
                save = YES;
            }
            if (![[self.event allKeys] containsObject:todayIsKey]) {
                [self.event setValue:@(todayIsNotCounted) forKey:todayIsKey];
                save = YES;
            }
            if ([[self.event allKeys] containsObject:dayOverKey]) {
                [self.event removeObjectForKey:dayOverKey];
                save = YES;
            }
            if (![[self.event allKeys] containsObject:showEventDatesKey]) {
                [self.event setValue:@(YES) forKey:showEventDatesKey];
                save = YES;
            }
            if (![[self.event allKeys] containsObject:showPercentageKey]) {
                [self.event setValue:@(YES) forKey:showPercentageKey];
                save = YES;
            }
            if (![[self.event allKeys] containsObject:showCompletedDaysKey]) {
                [self.event setValue:@(NO) forKey:showCompletedDaysKey];
                save = YES;
            }
            if (![[self.event allKeys] containsObject:showTotalsKey]) {
                [self.event setValue:@(YES) forKey:showTotalsKey];
                save = YES;
            }
            if (save) {
                [self saveEvent];
            }
		}
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// navigation items
	self.navigationItem.title = NSLocalizedString(@"Event",@"Title for event settings view");
	// cancel button
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																						  target:self
                                                                                          action:@selector(cancel)];
	// done button
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
                                                                                           action:@selector(done)];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.titleView.text = [self.event valueForKey:titleKey];
	self.titleView.borderStyle = UITextBorderStyleNone;
	[self clearDatePicker];
	self.showErrorAlert = YES;
	self.startDateViewCellIndexPath = [NSIndexPath indexPathForRow:START_DATE inSection:EVENT];
	self.endDateViewCellIndexPath = [NSIndexPath indexPathForRow:END_DATE inSection:EVENT];
    self.durationViewCellIndexPath = [NSIndexPath indexPathForRow:DURATION inSection:EVENT];
	// set the detailTextLabel.textColor since its not a built in color
	self.detailTextLabelColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
//	self.linkUnlinkedEventActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Link to Event in Calendar", @"Action sheet title to link event to system calendar")
//																	delegate:self
//														   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Button to not link event to calendar")
//													  destructiveButtonTitle:nil
//														   otherButtonTitles:NSLocalizedString(@"Existing Event", @"Button to link to event already in calendar"),
//										 NSLocalizedString(@"Create New Event", @"Button to create event in calendar"),
//										 nil];
//	self.changeLinkedEventActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Link to Event in Calendar", @"")
//																	delegate:self
//														   cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
//													  destructiveButtonTitle:NSLocalizedString(@"Remove Link", @"Button to unlink an event from the system calendar")
//														   otherButtonTitles:NSLocalizedString(@"Change Linked Event", @""),
//										 NSLocalizedString(@"Create New Event", @""),
//										 nil];
    // Add gesture recognized to handle taps between cells
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInputs)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    // Add duration cell, since it's accessory view is unique
    self.durationView.textColor = self.detailTextLabelColor;
    self.durationView.keyboardType = UIKeyboardTypeNumberPad;
    //	Doing_TimeAppDelegate *appDelegate = (Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate;
    //	self.eventStore = appDelegate.eventStore;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showDuration];
}

- (void)cancel {
	self.cancelling = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)done {
    if ([self verifyEvent]) {
        [self saveEvent];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (Boolean)verifyEvent {
	if (![self verifyNonemptyTitle]) {
		return NO;
	}
	if (![self verifyDateOrder]) {
		[self showDateErrorAlert];
		return NO;
	}
    if (self.duration <= 0) {
        [self showDurationErrorAlert];
        return NO;
    }
    return YES;
}

- (void)saveEvent {
	NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
	if (self.newEvent) {
		[events addObject:self.event];
	} else {
		[events replaceObjectAtIndex:self.index withObject:self.event];
	}
	[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Duration

- (void)calculateDuration {
    switch ([self.event[startKey] compare:self.event[endKey]]) {
        case NSOrderedAscending:
            self.duration = [[self.calendar components:NSDayCalendarUnit
                                              fromDate:self.event[startKey]
                                                toDate:self.event[endKey]
                                               options:0]
                             day];
            break;
        case NSOrderedSame:
            self.duration = 0;
            break;
        case NSOrderedDescending:
            self.duration = 0;
            return;
    }
    if ([self.event[includeLastDayInCalcKey] boolValue]) {
        self.duration = self.duration + 1;
    }
}

- (void)showDuration {
    if (self.event[startKey] && self.event[endKey]) {
        [self calculateDuration];
        self.durationView.text = [NSNumber numberWithUnsignedInteger:self.duration].stringValue;
    } else {
        self.durationView.text = nil;
    }
}

#pragma mark - Display Settings

- (void)switchIncludeLastDayInCalc:(id)sender {
    [self clearDatePicker];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:includeLastDayInCalcKey];
    [self showDuration];
}

- (void)switchShowEventDates:(id)sender {
    [self clearDatePicker];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showEventDatesKey];
    [self.tableView reloadData];
}

- (void)switchShowPercentages:(id)sender {
    [self clearDatePicker];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showPercentageKey];
    [self.tableView reloadData];
}

- (void)switchShowRemainingDays:(id)sender {
    // inverse of switch since setting is displayed using opposite language
    [self clearDatePicker];
    [self.event setValue:@(![(UISwitch *)sender isOn]) forKey:showCompletedDaysKey];
    [self.tableView reloadData];
}

- (void)switchShowTotals:(id)sender {
    [self clearDatePicker];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showTotalsKey];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case EVENT:
            return 4;
            break;
        case DATES:
            return 2; // no calendar linking yet
            break;
        case DISPLAY:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *DefaultCellIdentifier = @"DefaultCell";
	static NSString *SubtitleCellIdentifier = @"SubtitleCell";
	static NSString *Value1CellIdentifier = @"Value1Cell";
    
    UITableViewCell *cell;
	if ((indexPath.section == EVENT) || (indexPath.section == DATES && indexPath.row == TODAY_IS)) {
		cell = [tableView dequeueReusableCellWithIdentifier:Value1CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Value1CellIdentifier];
		}
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:SubtitleCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SubtitleCellIdentifier];
		}
	}
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
    switch (indexPath.section) {
        case EVENT:
            switch (indexPath.row) {
                case TITLE:
                    return self.titleViewCell;
                    break;
                case START_DATE:
                    cell.textLabel.text = NSLocalizedString(@"Start Date", @"Label for the day the event starts");
                    cell.detailTextLabel.textColor = self.detailTextLabelColor;
                    if (![[self.event valueForKey:startKey] isEqualToDate:[NSDate distantPast]]) {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[self.event valueForKey:startKey]
                                                                                   dateStyle:NSDateFormatterLongStyle
                                                                                   timeStyle:NSDateFormatterNoStyle];
                        if (![self verifyDateOrder]) {
                            cell.detailTextLabel.textColor = [UIColor redColor];
                        }
                    } else {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                   dateStyle:NSDateFormatterLongStyle
                                                                                   timeStyle:NSDateFormatterNoStyle];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];
                    }
                    break;
                case END_DATE:
                    cell.textLabel.text = NSLocalizedString(@"End Date", @"Label for the day the event ends");
                    cell.detailTextLabel.textColor = self.detailTextLabelColor;
                    if (![[self.event valueForKey:endKey] isEqualToDate:[NSDate distantFuture]]) {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[self.event valueForKey:endKey]
                                                                                   dateStyle:NSDateFormatterLongStyle
                                                                                   timeStyle:NSDateFormatterNoStyle];
                        if (![self verifyDateOrder]) {
                            cell.detailTextLabel.textColor = [UIColor redColor];
                        }
                    } else {
                        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                   dateStyle:NSDateFormatterLongStyle
                                                                                   timeStyle:NSDateFormatterNoStyle];
                        cell.detailTextLabel.textColor = [UIColor whiteColor];
                    }
                    break;
                case DURATION:
                    return self.durationViewCell;
                default:
                    break;
            }
            break;
        case DATES:
            switch (indexPath.row) {
                case INCLUDE_END:
					cell.textLabel.text = NSLocalizedString(@"Include End Date", @"Label for cell that includes checkmark to indicate that events are calculated to include the last day");
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView addTarget:self
                                                       action:@selector(switchIncludeLastDayInCalc:)
                                             forControlEvents:UIControlEventValueChanged];
					if ([[self.event valueForKey:includeLastDayInCalcKey] boolValue]) {
						[(UISwitch *)cell.accessoryView setOn:YES];
                        cell.detailTextLabel.text = NSLocalizedString(@"Event is through end date", @"Explanitory label for \"Include End Date\" if checked");
					} else {
						[(UISwitch *)cell.accessoryView setOn:NO];
                        cell.detailTextLabel.text = NSLocalizedString(@"Event is until end date", @"Explanitory label for \"Include End Date\" if not checked");
					}
                    break;
                case TODAY_IS:
                    cell.textLabel.text = NSLocalizedString(@"Treat Today As", @"Label for cell that shows how today is handled");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    switch ([[self.event valueForKey:todayIsKey] integerValue]) {
                        case todayIsOver:
                            cell.detailTextLabel.text = NSLocalizedString(@"Complete", @"Label for handling today as if it is already over");
                            break;
                        case todayIsNotCounted:
                            cell.detailTextLabel.text = NSLocalizedString(@"Uncounted", @"Label for handling today as if it is neither remaining or over");
                            break;
                        case todayIsRemaining:
                            cell.detailTextLabel.text = NSLocalizedString(@"Remaining", @"Label for handling today as if it is not yet over");
                            break;
                        default:
                            break;
                    }
                    break;
                case CALENDAR: // link to calendar
                    //                    cell.textLabel.text = NSLocalizedString(@"Link to Event", @"Label or button link event to the system calendar");
                    //                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    //                    if ([self.event valueForKey:linkKey]) {
                    //                        EKEvent *event = [self.eventStore eventWithIdentifier:[self.event valueForKey:linkKey]];
                    //                        cell.detailTextLabel.text = event.title; //event title
                    //                    } else {
                    //                        cell.detailTextLabel.text = NSLocalizedString(@"None", @"Label to indicate that event is not linked to the system calendar");
                    //                    }
                    break;
                default:
                    break;
            }
            break;
        case DISPLAY:
            switch (indexPath.row) {
                case SHOW_DATES:
                    cell.textLabel.text = NSLocalizedString(@"Show Dates", @"Label for cell that includes checkmark to indicate that event dates should be displayed");
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView addTarget:self
                                                       action:@selector(switchShowEventDates:)
                                             forControlEvents:UIControlEventValueChanged];
                    if ([[self.event valueForKey:showEventDatesKey] boolValue]) {
						[(UISwitch *)cell.accessoryView setOn:YES];
                        cell.detailTextLabel.text = NSLocalizedString(@"Event dates are displayed", @"Explanitory label for \"Show Dates\" if checked");
					} else {
						[(UISwitch *)cell.accessoryView setOn:NO];
                        cell.detailTextLabel.text = NSLocalizedString(@"Event dates are hidden", @"Explanitory label for \"Show Dates\" if not checked");
                    }
                    break;
                case SHOW_PERCENTS:
                    cell.textLabel.text = NSLocalizedString(@"Percentages", @"Label for cell that includes checkmark to indicate that events are displayed with percentages");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView addTarget:self
                                                       action:@selector(switchShowPercentages:)
                                             forControlEvents:UIControlEventValueChanged];
                    if ([[self.event valueForKey:showPercentageKey] boolValue]) {
                        [(UISwitch *)cell.accessoryView setOn:YES];
                        cell.detailTextLabel.text = NSLocalizedString(@"Percentages are shown", @"Explanitory label for \"Percentages\" if checked");
                    } else {
                        [(UISwitch *)cell.accessoryView setOn:NO];
                        cell.detailTextLabel.text = NSLocalizedString(@"Percentages are hidden", @"Explanitory label for \"Percentages\" if not checked");
                    }
                    break;
                case SHOW_TOTALS:
                    cell.textLabel.text = NSLocalizedString(@"Totals", @"Label for cell that includes checkmark to indicate that events are displayed with dates");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView addTarget:self
                                                       action:@selector(switchShowTotals:)
                                             forControlEvents:UIControlEventValueChanged];
                    if ([self.event[showTotalsKey] boolValue]) {
                        [(UISwitch *)cell.accessoryView setOn:YES];
                        cell.detailTextLabel.text = NSLocalizedString(@"Totals are shown", @"Explanitory label for \"Totals\" if checked");
                    } else {
                        [(UISwitch *)cell.accessoryView setOn:NO];
                        cell.detailTextLabel.text = NSLocalizedString(@"Totals are hidden", @"Explanitory label for \"Totals\" if not checked");
                    }
                    break;
                case SHOW_COMPLETE:
                    cell.textLabel.text = NSLocalizedString(@"Remaining Days Only", @"Label for cell that includes checkmark to indicate that events are displayed with the completed days count");
                    cell.detailTextLabel.text = @"";
                    // the text displayed to the user is the reverse of the setting
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView addTarget:self
                                                       action:@selector(switchShowRemainingDays:)
                                             forControlEvents:UIControlEventValueChanged];
                    if (![[self.event valueForKey:showCompletedDaysKey] boolValue]) {
                        [(UISwitch *)cell.accessoryView setOn:YES];
                        cell.detailTextLabel.text = NSLocalizedString(@"Completed days are hidden", @"Explanitory label for \"Remaining Days Only\" if checked");
                    } else {
                        [(UISwitch *)cell.accessoryView setOn:NO];
                        cell.detailTextLabel.text = NSLocalizedString(@"Completed days are shown", @"Explanitory label for \"Remaining Days Only\" if not checked");
                    }
                    break;
                default:
                    break;
            }
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case EVENT:
            return nil;
            break;
        case DATES:
            return NSLocalizedString(@"Dates", @"Heading for settings affecting date calculations");
            break;
        case DISPLAY:
			return NSLocalizedString(@"Display", @"Heading for settings affecting the display of events");
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
    /*
    switch (section) {
        case EVENT:
            return NSLocalizedString(@"Give the event a title and\nset the start and end dates.", @"Label with basic instructions for the user");
            break;
        default:
            return nil;
            break;
    }
     */
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *link;
	self.showErrorAlert = YES;
	[self verifyDateOrder];
    [self calculateDuration];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	self.datePicker.datePickerMode = UIDatePickerModeDate;
	if (indexPath.row || indexPath.section) {
		[self.titleView resignFirstResponder];
	}
    if (![indexPath isEqual:self.durationViewCellIndexPath]) {
        [self.durationView resignFirstResponder];
    }
    switch (indexPath.section) {
        case EVENT:
            switch (indexPath.row) {
                case TITLE:
                    break;
                case START_DATE:
                    if (!self.settingStartDate) {
                        self.settingEndDate = NO;
                        [self hideDatePicker:NO];
                        [self.datePicker setDate:[self.event valueForKey:startKey]
                                        animated:YES];
                        if ([[self.event valueForKey:startKey] isEqualToDate:[NSDate distantPast]]) {
                            [self.datePicker setDate:[NSDate date] animated:YES];
                        }
                        [self.datePicker removeTarget:self
                                               action:@selector(changeEndDate:)
                                     forControlEvents:UIControlEventValueChanged];
                        [self.datePicker addTarget:self
                                            action:@selector(changeStartDate:)
                                  forControlEvents:UIControlEventValueChanged];
                    } else {
                        [self hideDatePicker:YES];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                    self.settingStartDate = !self.settingStartDate;
                    break;
                case END_DATE:
                    if (!self.settingEndDate) {
                        self.settingStartDate = NO;
                        [self hideDatePicker:NO];
                        [self.datePicker setDate:[self.event valueForKey:endKey]
                                        animated:YES];
                        if ([[self.event valueForKey:endKey] isEqualToDate:[NSDate distantFuture]]) {
                            [self.datePicker setDate:[NSDate date] animated:YES];
                        }
                        [self.datePicker removeTarget:self
                                               action:@selector(changeStartDate:)
                                     forControlEvents:UIControlEventValueChanged];
                        [self.datePicker addTarget:self
                                            action:@selector(changeEndDate:)
                                  forControlEvents:UIControlEventValueChanged];
                    } else {
                        [self hideDatePicker:YES];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                    self.settingEndDate = !self.settingEndDate;
                    break;
                case DURATION:
                    break;
                default:
                    break;
            }
            break;
        case DATES:
            [self clearDatePicker];
            switch (indexPath.row) {
                case INCLUDE_END:
                    // include last day in calc is handled by trapping the switch change
                    [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case TODAY_IS:
                    if (YES) { // workaround inability to create object as first statement in case
                        TodaySettingsViewController *controller = [[TodaySettingsViewController alloc] initWithTodaySetting:[[self.event valueForKey:todayIsKey] integerValue]];
                        [[NSNotificationCenter defaultCenter] addObserverForName:todayIsKey
                                                                          object:controller
                                                                           queue:[NSOperationQueue currentQueue]
                                                                      usingBlock:^(NSNotification *note) {
                                                                          [self.event setValue:[note.userInfo valueForKey:todayIsKey] forKey:todayIsKey];
                                                                          [[NSNotificationCenter defaultCenter] removeObserver:self name:todayIsKey object:note.object];
                                                                          [self.tableView reloadData];
                                                                      }];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                    break;
                case CALENDAR:
                    link = [self.event valueForKey:linkKey];
                    if (link) {
                        [self.changeLinkedEventActionSheet showInView:self.view];
                    } else {
                        [self.linkUnlinkedEventActionSheet showInView:self.view];
                    }
                default:
                    break;
            }
            break;
        case DISPLAY:
            [self clearDatePicker];
            [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
            /*
            switch (indexPath.row) {
                case SHOW_DATES:
                    // show event dates is handled by trapping the switch change
                    [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case SHOW_PERCENTS:
                    // show percentages only is handled by trapping the switch change
                    [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case SHOW_COMPLETE:
                    // show only remaining days is handled by trapping the switch change
                    [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
             */
        default:
            break;
    }
}

//- (NSIndexPath *)tableView:tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (indexPath.row) {
//		if (![self verifyNonemptyTitle]) {
//			return [self.tableView indexPathForSelectedRow];
//		}
//	} else {
//		if (![self verifyDateOrder]) {
//			[self showDateErrorAlert];
//			[self clearDatePicker];
//			return nil;
//		}
//	}
//	return indexPath;
//}
//
#pragma mark -
#pragma mark Date Pickers

- (void)changeStartDate:(id)sender {
	[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
	[self.event setValue:[NSDate midnightForDate:self.datePicker.date] forKey:startKey];
	[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
																																 dateStyle:NSDateFormatterLongStyle
																																 timeStyle:NSDateFormatterNoStyle];
	[self verifyDateOrder];
    [self showDuration];
}

- (void)changeEndDate:(id)sender {
	[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
	[self.event setValue:[NSDate midnightForDate:self.datePicker.date] forKey:endKey];
	[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
																															   dateStyle:NSDateFormatterLongStyle
																															   timeStyle:NSDateFormatterNoStyle];
	[self verifyDateOrder];
    [self showDuration];
}

- (void)clearDatePicker {
	[self hideDatePicker:YES];
	[self.datePicker setDate:[NSDate date] animated:NO];
	self.settingStartDate = NO;
	self.settingEndDate = NO;
}

- (void)hideInputs {
    [self hideDatePicker:YES];
    [self.view endEditing:NO];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    self.settingEndDate = NO;
    self.settingStartDate = NO;
}

- (void)hideDatePicker:(BOOL)hidden {
	if (hidden != self.datePicker.hidden) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		if (!hidden) {
			self.datePicker.hidden = NO;
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height - self.datePicker.frame.size.height);
			self.datePicker.frame = CGRectOffset(self.datePicker.frame,
												 0,
												 -self.datePicker.frame.size.height);
		} else {
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height + self.datePicker.frame.size.height);
			self.datePicker.frame = CGRectOffset(self.datePicker.frame,
												 0,
												 self.datePicker.frame.size.height);
		}
		[UIView commitAnimations];
		self.datePicker.hidden = hidden;
	}
}

- (void)showDateErrorAlert {
	if (self.showErrorAlert) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Save Event", @"Title for error saving event")
														message:NSLocalizedString(@"The start date must be before the end date.", @"Label indicating that the start day is not before the end day")
													   delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Label indicating the user acknowledges the issue")
											  otherButtonTitles:nil];
		[alert show];
		self.showErrorAlert = NO;
	}
}

- (void)showDurationErrorAlert {
	if (self.showErrorAlert) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Save Event", @"Title for error saving event")
														message:NSLocalizedString(@"Event must be 1 or more days long.\n\nInclude the end date in the event\nor change the end date.", @"Label indicating that event has zero days duration")
													   delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"Label indicating the user acknowledges the issue")
											  otherButtonTitles:nil];
		[alert show];
		self.showErrorAlert = NO;
	}
}

- (BOOL)verifyDateOrder {
	BOOL inOrder = YES;
	NSDate *start = [self.event valueForKey:startKey];
	NSDate *end = [self.event valueForKey:endKey];
	NSDate *later = [start laterDate:end];
	inOrder = !([start isEqualToDate:later] && ![start isEqualToDate:end]);
	if ([[self.tableView indexPathForSelectedRow] compare:self.startDateViewCellIndexPath] == NSOrderedSame) {
		if (!inOrder) {
			[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = [UIColor redColor];
		} else {
			[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
		}
	} else if ([[self.tableView indexPathForSelectedRow] compare:self.endDateViewCellIndexPath] == NSOrderedSame) {
		if (!inOrder) {
			[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = [UIColor redColor];
		} else {
			[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
		}
	} else if (!inOrder) {
		[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = [UIColor redColor];
		[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = [UIColor redColor];
	} else {
		[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
		[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
	}
	if ([[self.event valueForKey:startKey] isEqualToDate:[NSDate distantPast]]) {
		[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = [UIColor whiteColor];
	}
	if ([[self.event valueForKey:endKey] isEqualToDate:[NSDate distantFuture]]) {
		[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = [UIColor whiteColor];
	}
	return inOrder;
}

//#pragma mark -
//#pragma mark Calendar Events
//
//- (void)createCalendarEvent {
//	EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
//    controller.eventStore = self.eventStore;
//    controller.editViewDelegate = self;
//    [self presentModalViewController: controller animated:YES];
//}
//
//- (void)editCalendarEvent:(NSString *)identifier {
//
//}
//
//- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
//	if (action == EKEventEditViewActionSaved) {
//		EKEvent* event = controller.event;
//		[[NSUserDefaults standardUserDefaults] setObject:event.title forKey:titleKey];
//		[[NSUserDefaults standardUserDefaults] setObject:event.startDate forKey:startKey];
//		[[NSUserDefaults standardUserDefaults] setObject:event.endDate forKey:endKey];
//		[[NSUserDefaults standardUserDefaults] setObject:event.eventIdentifier forKey:linkKey];
//		[self.tableView reloadData];
//	}
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)selectCalendarEvent {
//
//}
//
#pragma mark -
#pragma mark Text field delegate

- (BOOL)verifyNonemptyTitle {
	if (!self.cancelling) {
		if ([self.titleView.text length]) {
			[self.event setValue:self.titleView.text forKey:titleKey];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Save Title", @"Title for message indicating an error with the title of the event")
															message:NSLocalizedString(@"The title cannot be blank.", @"Message with the cause of the error saving the title")
														   delegate:nil
												  cancelButtonTitle:NSLocalizedString(@"OK", @"")
												  otherButtonTitles:nil];
			[alert show];
			return NO;
		}
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.titleView]) {
        if (![self verifyNonemptyTitle]) {
            [self.titleView becomeFirstResponder];
        }
    } else if (self.durationView.text.length) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.day = [self.durationView.text integerValue];
        if (!self.event[includeLastDayInCalcKey]) {
            offsetComponents.day = offsetComponents.day + 1;
        }
        self.event[endKey] = [self.calendar dateByAddingComponents:offsetComponents toDate:self.event[startKey] options:0];
        [self.tableView reloadRowsAtIndexPaths:@[self.endDateViewCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self showDuration];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self hideDatePicker:YES];
	self.settingStartDate = NO;
	self.settingEndDate = NO;
    if ([textField isEqual:self.durationView]) {
        self.durationView.text = nil;
    }
}

#pragma mark -
#pragma mark Action sheet view delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //	if (actionSheet == self.linkUnlinkedEventActionSheet) {
    //		if (buttonIndex == actionSheet.cancelButtonIndex) {
    //			// do nothing
    //		} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
    //			[self selectCalendarEvent];
    //		} else {
    //			[self createCalendarEvent];
    //		}
    //	} else if (actionSheet == self.changeLinkedEventActionSheet) {
    //		if (buttonIndex == actionSheet.cancelButtonIndex) {
    //			// do nothing
    //		} else if (buttonIndex == actionSheet.destructiveButtonIndex) {
    //			[self.event setValue:nil forKey:linkKey];
    //		} else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
    //			[self selectCalendarEvent];
    //		} else {
    //			[self createCalendarEvent];
    //		}
    //	}
    //	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[super viewDidUnload];
}

@end
