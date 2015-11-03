//
//  EventSettingsViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//
//  Copyright (c) 2010-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <MessageUI/MessageUI.h>
#import "NSDate+Additions.h"
//#import <EventKit/EventKit.h>
//#import <EventKitUI/EventKitUI.h>

@class ColorPickerViewController;

@interface EventSettingsViewController : UITableViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	NSMutableDictionary* _event;
//	UIDatePicker* _datePicker;
//	EKEventStore* _eventStore;
	NSIndexPath* _startDateViewCellIndexPath;
	NSIndexPath* _endDateViewCellIndexPath;
	UIColor* _detailTextLabelColor;
	UIActionSheet* _linkUnlinkedEventActionSheet;
	UIActionSheet* _changeLinkedEventActionSheet;
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

//#pragma mark - Calendar Events
//
//- (void)createCalendarEvent;
//- (void)editCalendarEvent:(NSString *)identifier;
//- (void)selectCalendarEvent;

#pragma mark - Properties

@property NSUInteger index;
@property (nonatomic, strong) NSMutableDictionary* event;
@property BOOL settingStartDate;
@property BOOL settingEndDate;
@property BOOL showErrorAlert;
@property BOOL newEvent;
//@property (nonatomic, strong) IBOutlet EKEventStore* eventStore;
@property (nonatomic, strong) NSIndexPath* startDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* startDatePickerViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* endDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* endDatePickerViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* durationViewCellIndexPath;
@property (nonatomic, strong) UIColor* detailTextLabelColor;
@property (nonatomic, strong) UIActionSheet* linkUnlinkedEventActionSheet;
@property (nonatomic, strong) UIActionSheet* changeLinkedEventActionSheet;
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