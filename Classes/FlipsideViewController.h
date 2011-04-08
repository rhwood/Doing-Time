//
//  FlipsideViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "NSDate+Additions.h"
#import "Constants.h"

@protocol FlipsideViewControllerDelegate;

@class Doing_TimeAppDelegate;
@class EventSettingsViewController;

@interface FlipsideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	UITableView* _tableView;
	UIDatePicker* _datePicker;
	BOOL showErrorAlert;
	NSIndexPath* _endingTimeViewCellIndexPath;
	UIColor* _detailTextLabelColor;
	Doing_TimeAppDelegate* _appDelegate;
	
	// Pause UI while waiting
	
	UIView* _waitingView;
	UIActivityIndicatorView* _waitingIndicator;
	UILabel* _waitingText;
	
}

#pragma mark -
#pragma mark Navigation Controls

- (IBAction)done:(id)sender;
- (void)setEditButton;

#pragma mark -
#pragma mark Events

- (void)addEvent;

#pragma mark -
#pragma mark Date picker

- (void)changeEndingTime:(id)sender;
- (void)hideDatePicker:(BOOL)hidden;

#pragma mark -
#pragma mark Purchases

- (void)hidePurchaseActivity:(BOOL)hidden;

#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIDatePicker* datePicker;
@property BOOL showErrorAlert;
@property (nonatomic, retain) NSIndexPath* endingTimeViewCellIndexPath;
@property (nonatomic, retain) UIColor* detailTextLabelColor;
@property (nonatomic, retain) Doing_TimeAppDelegate* appDelegate;

@property (nonatomic, retain) IBOutlet UIView* waitingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* waitingIndicator;
@property (nonatomic, retain) IBOutlet UILabel* waitingText;

@end

#pragma mark -
#pragma mark Flipside View Controller Delegate Protocol

@protocol FlipsideViewControllerDelegate

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (void)eventDidUpdate:(NSUInteger)eventIdentifier;
- (void)eventDidMove:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex;
- (void)eventWasRemoved:(NSUInteger)eventIdentifier;
- (void)eventDisplayMethodUpdated;

@end

