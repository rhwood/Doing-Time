//
//  FlipsideViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "NSDate+Additions.h"
#import "Constants.h"

@protocol FlipsideViewControllerDelegate;

@class Doing_TimeAppDelegate;
@class EventSettingsViewController;

@interface FlipsideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	UITableView* _tableView;
	UIDatePicker* _datePicker;
	BOOL showErrorAlert;
	NSIndexPath* _endingTimeViewCellIndexPath;
	UIColor* _detailTextLabelColor;
	Doing_TimeAppDelegate* _appDelegate;
	NSUInteger eventBeingUpdated;
	
	// Purchases
	BOOL appStoreRequestFailed;
	
	// Activity
	UIActivityIndicatorView* _activityIndicator;
	UILabel* _activityLabel;
	UIView* _activityView;
	
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

@property BOOL appStoreRequestFailed;
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
@property NSUInteger eventBeingUpdated;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel* activityLabel;
@property (nonatomic, retain) IBOutlet UIView* activityView;

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

