//
//  EventSettingsViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "NSDate+Additions.h"
//#import <EventKit/EventKit.h>
//#import <EventKitUI/EventKitUI.h>

@interface EventSettingsViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	NSUInteger _index;
	NSMutableDictionary* _event;
	UITableView* _tableView;
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
	UITableViewCell *_titleViewCell;
	BOOL cancelling;
}

- (id)initWithEventIndex:(NSUInteger)index;
- (void)cancel;
- (void)done;
- (Boolean)verifyEvent;
- (void)saveEvent;
- (BOOL)verifyNonemptyTitle;
- (void)calculateDuration;
- (void)hideInputs;

#pragma mark - Display Settings

- (IBAction)switchIncludeLastDayInCalc:(id)sender;
- (IBAction)switchShowEventDates:(id)sender;
- (IBAction)switchShowPercentages:(id)sender;
- (IBAction)switchShowRemainingDays:(id)sender;
- (IBAction)switchShowTotals:(id)sender;

#pragma mark -
#pragma mark Date pickers

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
@property (nonatomic, strong) IBOutlet UITableView* tableView;
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
@property (nonatomic, strong) IBOutlet UITableViewCell* titleViewCell;
@property (nonatomic, strong) IBOutlet UITextField* durationView;
@property (nonatomic, strong) IBOutlet UITableViewCell* durationViewCell;
@property BOOL cancelling;
@property NSUInteger duration;
@property (nonatomic, strong) NSCalendar *calendar;

@end