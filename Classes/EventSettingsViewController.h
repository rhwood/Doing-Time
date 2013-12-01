//
//  EventSettingsViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "NSDate+Additions.h"
//#import <EventKit/EventKit.h>
//#import <EventKitUI/EventKitUI.h>

@class ColorPickerViewController;

@interface EventSettingsViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	NSMutableDictionary* _event;
	UIDatePicker* _datePicker;
	BOOL settingStartDate;
	BOOL settingEndDate;
	BOOL showErrorAlert;
	BOOL newEvent;
//	EKEventStore* _eventStore;
	NSIndexPath* _startDateViewCellIndexPath;
	NSIndexPath* _endDateViewCellIndexPath;
	UIColor* _detailTextLabelColor;
	UIActionSheet* _linkUnlinkedEventActionSheet;
	UIActionSheet* _changeLinkedEventActionSheet;
	__unsafe_unretained UITextField *_titleView;
	BOOL cancelling;

	// In-App Purchases
	BOOL appStoreRequestFailed;

}

- (void)cancel;
- (void)done;
- (Boolean)verifyEvent;
- (void)saveEvent;
- (BOOL)verifyNonemptyTitle;
- (void)hideInputs;

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

#pragma mark - Date pickers

- (void)changeStartDate:(id)sender;
- (void)changeEndDate:(id)sender;
- (void)clearDatePicker;
- (void)hideDatePicker:(BOOL)hidden;
- (void)showDateErrorAlert;
- (void)showDurationErrorAlert;
- (BOOL)verifyDateOrder;

//#pragma mark -
//#pragma mark Calendar Events
//
//- (void)createCalendarEvent;
//- (void)editCalendarEvent:(NSString *)identifier;
//- (void)selectCalendarEvent;

#pragma mark -
#pragma mark Properties

@property NSUInteger index;
@property (nonatomic, strong) NSMutableDictionary* event;
@property (nonatomic, strong) IBOutlet UIDatePicker* datePicker;
@property BOOL settingStartDate;
@property BOOL settingEndDate;
@property BOOL showErrorAlert;
@property BOOL newEvent;
//@property (nonatomic, strong) IBOutlet EKEventStore* eventStore;
@property (nonatomic, strong) NSIndexPath* startDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* endDateViewCellIndexPath;
@property (nonatomic, strong) NSIndexPath* durationViewCellIndexPath;
@property (nonatomic, strong) UIColor* detailTextLabelColor;
@property (nonatomic, strong) UIActionSheet* linkUnlinkedEventActionSheet;
@property (nonatomic, strong) UIActionSheet* changeLinkedEventActionSheet;
@property (nonatomic, assign) IBOutlet UITextField* titleView;
@property (nonatomic, strong) IBOutlet UITextField* durationView;
@property (nonatomic, strong) IBOutlet UITableViewCell* durationViewCell;
@property (nonatomic, strong) IBOutlet UITextView* urlView;
@property (nonatomic, strong) IBOutlet UITableViewCell* urlViewCell;
@property BOOL cancelling;
@property NSUInteger duration;
@property (nonatomic, strong) NSCalendar *calendar;

// purchase support
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel* activityLabel;
@property (nonatomic, strong) IBOutlet UIView* activityView;

// Color picking
@property (nonatomic, strong) ColorPickerViewController* colorPicker;

@end