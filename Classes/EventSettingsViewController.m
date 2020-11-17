//
//  EventSettingsViewController.m
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

#import "EventSettingsViewController.h"
#import "TodaySettingsViewController.h"
#import "MainViewController.h"
#import "AboutViewController.h"
#import "Constants.h"

// Table Event section
#define EVENT 0
#define TITLE 0
#define START_DATE 1
#define START_DATE_PICKER 2
#define END_DATE 3
#define END_DATE_PICKER 4
#define DURATION 5
// Table Dates section
#define DATES 1
#define INCLUDE_END 0
#define TODAY_IS 1
// Table Stats section
#define DISPLAY 2
#define SHOW_DATES 0
#define SHOW_PERCENTS 1
#define SHOW_TOTALS 2
#define SHOW_COMPLETE 3
#define COMPLETED_COLOR 4
#define REMAINING_COLOR 5
#define BACKGROUND_COLOR 6
// Table URL section
#define URL_SECT -1 // effectively disable
#define URL_CELL 0

@interface EventSettingsViewController ()

- (void)colorSelectionDidChange:(NSNotification *)note forKey:(NSString *)key;

- (void)clearDatePickerAndSelection;

@end

@implementation EventSettingsViewController

@synthesize index = _index;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		self.index = 0;
        self.settingEndDate = NO;
        self.settingStartDate = NO;
    }
    return self;
}

- (NSUInteger)index {
    return _index;
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    UIColor *red = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:1.0];
    UIColor *green = [UIColor colorWithRed:0.0 green:0.6 blue:0.0 alpha:1.0];
    UIColor *blue = [UIColor colorWithRed:0.0 green:0.0 blue:0.6 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    if (index == [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count] || ![[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:index]) {
        self.newEvent = YES;
        self.event = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                     titleKey:@"",
                                                                     startKey:[NSDate date],
                                                                     endKey:[NSDate date],
                                                                     includeLastDayInCalcKey:@(YES),
                                                                     todayIsKey:@(todayIsNotCounted),
                                                                     showEventDatesKey:@(YES),
                                                                     showPercentageKey:@(YES),
                                                                     showCompletedDaysKey:@(NO),
                                                                     showTotalsKey:@(YES),
                                                                     backgroundColorKey:[NSKeyedArchiver archivedDataWithRootObject:white]}];
        [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:green] forKey:completedColorKey];
        [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:red] forKey:remainingColorKey];
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
        if (![self.event.allKeys containsObject:backgroundColorKey]) {
            [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:white] forKey:backgroundColorKey];
            save = YES;
        }
        if (![self.event.allKeys containsObject:completedColorKey]) {
            switch (index % 3) {
                case 0:
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:green] forKey:completedColorKey];
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:red] forKey:remainingColorKey];
                    break;
                case 1:
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:red] forKey:completedColorKey];
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:blue] forKey:remainingColorKey];
                    break;
                case 2:
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:blue] forKey:completedColorKey];
                    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:green] forKey:remainingColorKey];
                    break;
            }
            save = YES;
        }
        if (save) {
            [self saveEvent];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelling = NO;
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.titleView.text = [self.event valueForKey:titleKey];
    self.titleView.borderStyle = UITextBorderStyleNone;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.showErrorAlert = YES;
    self.startDateViewCellIndexPath = [NSIndexPath indexPathForRow:START_DATE inSection:EVENT];
    self.startDatePickerViewCellIndexPath = [NSIndexPath indexPathForRow:START_DATE_PICKER inSection:EVENT];
    self.endDateViewCellIndexPath = [NSIndexPath indexPathForRow:END_DATE inSection:EVENT];
    self.endDatePickerViewCellIndexPath = [NSIndexPath indexPathForRow:END_DATE_PICKER inSection:EVENT];
    self.durationViewCellIndexPath = [NSIndexPath indexPathForRow:DURATION inSection:EVENT];
    // set the detailTextLabel.textColor to ~ Brunswick Green (per Wikipedia)
    self.detailTextLabelColor = [UIColor colorWithRed:0.105 green:0.301 blue:0.242 alpha:1.0];
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
    // Add duration cell, since it's accessory view is unique
    self.durationView.textColor = self.detailTextLabelColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showDuration];
    if (self.newEvent) {
        [self.titleView becomeFirstResponder];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EventToTodayIsSegue"]) {
        TodaySettingsViewController *destination = segue.destinationViewController;
        destination.setting = [[self.event valueForKey:todayIsKey] integerValue];
        [[NSNotificationCenter defaultCenter] addObserverForName:todayIsKey
                                                          object:destination
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [self.event setValue:[note.userInfo valueForKey:todayIsKey] forKey:todayIsKey];
                                                          [[NSNotificationCenter defaultCenter] removeObserver:self name:todayIsKey object:note.object];
                                                          [self.tableView reloadData];
                                                      }];
    }
}

- (void)colorSelectionDidChange:(NSNotification *)note forKey:(NSString *)key {
}

- (void)cancel:(id)sender {
    [self cancel];
}

- (void)cancel {
    self.cancelling = YES;
    if ([self.navigationController.viewControllers[0] isEqual:self]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)done:(id)sender {
    [self done];
}

- (void)done {
    if ([self verifyEvent]) {
        [self saveEvent];
        if ([self.navigationController.viewControllers[0] isEqual:self]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:eventSavedNotification object:nil userInfo:@{eventsKey:[NSNumber numberWithInteger:self.index]}];
}

#pragma mark - Duration

- (void)calculateDuration {
    switch ([self.event[startKey] compare:self.event[endKey]]) {
        case NSOrderedAscending:
            self.duration = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
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
    if ([self.event[endKey] isEqualToDate:[NSDate distantFuture]] ||
        [self.event[startKey] isEqualToDate:[NSDate distantPast]]) {
        self.durationView.text = nil;
    } else {
        [self calculateDuration];
        self.durationView.text = [NSNumber numberWithUnsignedInteger:self.duration].stringValue;
    }
}

#pragma mark - Display Settings

- (void)switchIncludeLastDayInCalc:(id)sender {
    [self clearDatePickerAndSelection];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:includeLastDayInCalcKey];
    [self showDuration];
}

- (void)switchShowEventDates:(id)sender {
    [self clearDatePickerAndSelection];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showEventDatesKey];
    [self.tableView reloadData];
}

- (void)switchShowPercentages:(id)sender {
    [self clearDatePickerAndSelection];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showPercentageKey];
    [self.tableView reloadData];
}

- (void)switchShowRemainingDays:(id)sender {
    // inverse of switch since setting is displayed using opposite language
    [self clearDatePickerAndSelection];
    [self.event setValue:@(![(UISwitch *)sender isOn]) forKey:showCompletedDaysKey];
    [self.tableView reloadData];
}

- (void)switchShowTotals:(id)sender {
    [self clearDatePickerAndSelection];
    [self.event setValue:@([(UISwitch *)sender isOn]) forKey:showTotalsKey];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; // set to 4 to enable the URL
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case EVENT:
            return 6;
            break;
        case DATES:
            return 2; // no calendar linking yet
            break;
        case DISPLAY:
            return 7;
            break;
            //        case URL_SECT:
            //            return 1;
            //            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIColorWell *well = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case EVENT:
            switch (indexPath.row) {
                case TITLE:
                    // nothing to do
                    break;
                case START_DATE:
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
                case START_DATE_PICKER:
                    // nothing to do
                    break;
                case END_DATE:
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
                case END_DATE_PICKER:
                    // nothing to do
                    break;
                case DURATION:
                    // nothing to do
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
                case COMPLETED_COLOR:
                    well = [[UIColorWell alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, 0.0)];
                    cell.accessoryView = well;
                    well.selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:self.event[completedColorKey]];
                    [well addTarget:self action:@selector(setCompletedColor:) forControlEvents:UIControlEventValueChanged];
                    break;
                case REMAINING_COLOR:
                    well = [[UIColorWell alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, cell.frame.size.height)];
                    cell.accessoryView = well;
                    well.selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:self.event[remainingColorKey]];
                    [well addTarget:self action:@selector(setRemainingColor:) forControlEvents:UIControlEventValueChanged];
                    break;
                case BACKGROUND_COLOR:
                    well = [[UIColorWell alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, cell.frame.size.height)];
                    cell.accessoryView = well;
                    well.selectedColor = [NSKeyedUnarchiver unarchiveObjectWithData:self.event[backgroundColorKey]];
                    [well addTarget:self action:@selector(setBackgroundColor:) forControlEvents:UIControlEventValueChanged];
                    break;
                default:
                    break;
            }
            break;
            //        case URL_SECT:
            //            switch (indexPath.row) {
            //                case URL_CELL:
            //                    return self.urlViewCell;
            //                default:
            //                    break;
            //            }
            //            break;
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
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
    /*
     switch (section) {
     case EVENT:
     return [NSString stringWithFormat:@"doing-time-app://?%@", [self.event[titleKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == EVENT) {
        if (indexPath.row == START_DATE_PICKER) {
            return (self.settingStartDate) ? self.startDatePicker.bounds.size.height : 0.0;
        }
        if (indexPath.row == END_DATE_PICKER) {
            return (self.settingEndDate) ? self.endDatePicker.bounds.size.height : 0.0;
        }
    }
    return tableView.rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    self.showErrorAlert = YES;
    [self verifyDateOrder];
    [self calculateDuration];
    if (indexPath.row || indexPath.section) {
        [self.titleView resignFirstResponder];
    }
    if (![indexPath isEqual:self.durationViewCellIndexPath]) {
        [self.durationView resignFirstResponder];
    }
    switch (indexPath.section) {
        case EVENT:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            switch (indexPath.row) {
                case TITLE:
                    self.settingStartDate = NO;
                    self.settingEndDate = NO;
                    [self.titleView becomeFirstResponder];
                    break;
                case START_DATE:
                    if (!self.settingStartDate) {
                        self.settingEndDate = NO;
                        [self.startDatePicker setDate:[self.event valueForKey:startKey] animated:YES];
                    }
                    self.settingStartDate = !self.settingStartDate;
                    self.settingEndDate = NO;
                    // why doesn't next line work?
                    // [tableView reloadRowsAtIndexPaths:@[self.startDatePickerViewCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView reloadData];
                    break;
                case END_DATE:
                    if (!self.settingEndDate) {
                        self.settingStartDate = NO;
                        [self.endDatePicker setDate:[self.event valueForKey:endKey] animated:YES];
                    }
                    self.settingStartDate = NO;
                    self.settingEndDate = !self.settingEndDate;
                    // why doesn't next line work?
                    // [tableView reloadRowsAtIndexPaths:@[self.endDatePickerViewCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView reloadData];
                    break;
                case DURATION:
                    self.settingStartDate = NO;
                    self.settingEndDate = NO;
                    [self.durationView becomeFirstResponder];
                    break;
                default:
                    break;
            }
            break;
        case DATES:
            switch (indexPath.row) {
                case INCLUDE_END:
                    // include last day in calc is handled by trapping the switch change
                    [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case TODAY_IS:
                    // nothing to do
                    break;
                default:
                    break;
            }
            break;
        case DISPLAY:
            // every cell either performs a segue or has a switch
            [tableView cellForRowAtIndexPath:indexPath].selectionStyle = UITableViewCellSelectionStyleNone;
            break;
    }
}

#pragma mark - Date Pickers

- (void)changeStartDate:(id)sender {
    [self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
    [self.event setValue:[NSDate midnightForDate:self.startDatePicker.date] forKey:startKey];
    [self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath].detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.startDatePicker.date
                                                                                                                                 dateStyle:NSDateFormatterLongStyle
                                                                                                                                 timeStyle:NSDateFormatterNoStyle];
    [self verifyDateOrder];
    [self showDuration];
}

- (void)changeEndDate:(id)sender {
    [self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.textColor = self.detailTextLabelColor;
    [self.event setValue:[NSDate midnightForDate:self.endDatePicker.date] forKey:endKey];
    [self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath].detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.endDatePicker.date
                                                                                                                               dateStyle:NSDateFormatterLongStyle
                                                                                                                               timeStyle:NSDateFormatterNoStyle];
    [self verifyDateOrder];
    [self showDuration];
}

- (void)clearDatePickerAndSelection {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)hideInputs:(id)sender {
    [self.view endEditing:NO];
    [self clearDatePickerAndSelection];
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

//#pragma mark - Calendar Events
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
#pragma mark - Text field delegate

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
//        if (![self verifyNonemptyTitle]) {
//            [self.titleView becomeFirstResponder];
//        }
    } else if (self.durationView.text.length && ![self.event[startKey] isEqualToDate:[NSDate distantPast]]) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.day = [self.durationView.text integerValue];
        if (!self.event[includeLastDayInCalcKey]) {
            offsetComponents.day = offsetComponents.day + 1;
        }
        self.event[endKey] = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:self.event[startKey] options:0];
        [self.tableView reloadRowsAtIndexPaths:@[self.endDateViewCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self showDuration];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.settingStartDate = NO;
    self.settingEndDate = NO;
    [self.tableView reloadRowsAtIndexPaths:@[self.startDatePickerViewCellIndexPath, self.endDatePickerViewCellIndexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // prevent the gesture recognizer from hiding the date picker
    if ([touch.view isDescendantOfView:[self.tableView cellForRowAtIndexPath:self.startDateViewCellIndexPath]] ||
        [touch.view isDescendantOfView:[self.tableView cellForRowAtIndexPath:self.endDateViewCellIndexPath]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Mail composition delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action targets

- (IBAction)setCompletedColor:(id)sender {
    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:((UIColorWell *)sender).selectedColor] forKey:completedColorKey];
}

- (IBAction)setRemainingColor:(id)sender {
    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:((UIColorWell *)sender).selectedColor] forKey:remainingColorKey];
}

- (IBAction)setBackgroundColor:(id)sender {
    [self.event setValue:[NSKeyedArchiver archivedDataWithRootObject:((UIColorWell *)sender).selectedColor] forKey:backgroundColorKey];
}

@end
