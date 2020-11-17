//
//  EventSettingsViewController.h
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

#import <MessageUI/MessageUI.h>
#import "NSDate+Additions.h"

@class ColorPickerViewController;

@interface EventSettingsViewController : UITableViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	NSMutableDictionary* _event;
	NSIndexPath* _startDateViewCellIndexPath;
	NSIndexPath* _endDateViewCellIndexPath;
	UIColor* _detailTextLabelColor;
	__unsafe_unretained UITextField *_titleView;

}

- (void)cancel;
- (void)done;
- (Boolean)verifyEvent;
- (void)saveEvent;
- (BOOL)verifyNonemptyTitle;
- (IBAction)hideInputs:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

#pragma mark - Duration

- (void)calculateDuration;
- (void)showDuration;

#pragma mark - Display Settings

- (IBAction)switchIncludeLastDayInCalc:(id)sender;
- (IBAction)switchShowEventDates:(id)sender;
- (IBAction)switchShowPercentages:(id)sender;
- (IBAction)switchShowRemainingDays:(id)sender;
- (IBAction)switchShowTotals:(id)sender;

#pragma mark - Table cells

@property (weak) IBOutlet UITableViewCell *titleCell;
@property (weak) IBOutlet UITableViewCell *startDateCell;
@property (weak) IBOutlet UITableViewCell *endDateCell;
@property (weak) IBOutlet UITableViewCell *durationCell;

@property (weak) IBOutlet UITableViewCell *includeEndDateCell;
@property (weak) IBOutlet UITableViewCell *todayIsCell;

@property (weak) IBOutlet UITableViewCell *showDatesCell;
@property (weak) IBOutlet UITableViewCell *showPercentagesCell;
@property (weak) IBOutlet UITableViewCell *showTotalsCell;
@property (weak) IBOutlet UITableViewCell *showRemainingDaysOnlyCell;
@property (weak) IBOutlet UITableViewCell *completedDaysColorCell;
@property (weak) IBOutlet UITableViewCell *remainingDaysColorCell;
@property (weak) IBOutlet UITableViewCell *backgroundColorCell;
@property (weak) IBOutlet UIDatePicker *startDatePicker;
@property (weak) IBOutlet UIDatePicker *endDatePicker;

#pragma mark - Date pickers

- (IBAction)changeStartDate:(id)sender;
- (IBAction)changeEndDate:(id)sender;
- (void)showDateErrorAlert;
- (void)showDurationErrorAlert;
- (BOOL)verifyDateOrder;

#pragma mark - Properties

@property NSUInteger index;
@property (nonatomic, strong) NSMutableDictionary* event;
@property BOOL settingStartDate;
@property BOOL settingEndDate;
@property BOOL showErrorAlert;
@property BOOL newEvent;
@property (nonatomic, strong) NSIndexPath* startDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* startDatePickerViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* endDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* endDatePickerViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* durationViewCellIndexPath;
@property (nonatomic, strong) UIColor* detailTextLabelColor;
@property (nonatomic, assign) IBOutlet UITextField* titleView;
@property (nonatomic, strong) IBOutlet UITextField* durationView;
@property (nonatomic, strong) IBOutlet UITableViewCell* durationViewCell;
@property (nonatomic, strong) IBOutlet UITextView* urlView;
@property (nonatomic, strong) IBOutlet UITableViewCell* urlViewCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* startDatePickerViewCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* endDatePickerViewCell;
@property BOOL cancelling;
@property NSUInteger duration;

// purchase support
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel* activityLabel;
@property (nonatomic, strong) IBOutlet UIView* activityView;

// Color picking
@property (nonatomic, strong) ColorPickerViewController* colorPicker;

@end
