//
//  EventSettingsViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "NSDate+Additions.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface EventSettingsViewController : UIViewController <EKEventEditViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	NSUInteger _index;
	NSMutableDictionary* _event;
	UITableView* _tableView;
	UIDatePicker* _datePicker;
	BOOL settingStartDate;
	BOOL settingEndDate;
	BOOL showErrorAlert;
	BOOL newEvent;
	EKEventStore* _eventStore;
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
- (void)saveEvent;
- (BOOL)verifyNonemptyTitle;
- (IBAction)switchIncludeLastDayInCalc:(id)sender;

#pragma mark -
#pragma mark Date pickers

- (void)changeStartDate:(id)sender;
- (void)changeEndDate:(id)sender;
- (void)clearDatePicker;
- (void)hideDatePicker:(BOOL)hidden;
- (void)showDateErrorAlert;
- (BOOL)verifyDateOrder;

#pragma mark -
#pragma mark Calendar Events

- (void)createCalendarEvent;
- (void)editCalendarEvent:(NSString *)identifier;
- (void)selectCalendarEvent;

#pragma mark -
#pragma mark Properties

@property NSUInteger index;
@property (nonatomic, retain) NSMutableDictionary* event;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;
@property BOOL settingStartDate;
@property BOOL settingEndDate;
@property BOOL showErrorAlert;
@property BOOL newEvent;
@property (nonatomic, retain) IBOutlet EKEventStore* eventStore;
@property (nonatomic, retain) NSIndexPath* startDateViewCellIndexPath;
@property (nonatomic, retain) NSIndexPath* endDateViewCellIndexPath;
@property (nonatomic, retain) UIColor* detailTextLabelColor;
@property (nonatomic, retain) UIActionSheet* linkUnlinkedEventActionSheet;
@property (nonatomic, retain) UIActionSheet* changeLinkedEventActionSheet;
@property (nonatomic, assign) IBOutlet UITextField* titleView;
@property (nonatomic, retain) IBOutlet UITableViewCell* titleViewCell;
@property BOOL cancelling;

@end