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
	__unsafe_unretained id <FlipsideViewControllerDelegate> delegate;
	UITableView* _tableView;
	BOOL showErrorAlert;
	UIColor* _detailTextLabelColor;
	Doing_TimeAppDelegate* _appDelegate;
	NSUInteger eventBeingUpdated;
	
	// Purchases
	BOOL appStoreRequestFailed;
    BOOL allowInAppPurchases; // result of Lodsys patent threats
	
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
- (void)editEvent:(NSUInteger)eventID;

#pragma mark -
#pragma mark Purchases

@property BOOL appStoreRequestFailed;
@property BOOL allowInAppPurchases;
- (void)hidePurchaseActivity:(BOOL)hidden;

#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property BOOL showErrorAlert;
@property (nonatomic, strong) NSIndexPath* endingTimeViewCellIndexPath;
@property (nonatomic, strong) UIColor* detailTextLabelColor;
@property (nonatomic, strong) Doing_TimeAppDelegate* appDelegate;
@property NSUInteger eventBeingUpdated;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel* activityLabel;
@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (strong, retain) UIPanGestureRecognizer* swipe;
@property (strong, retain) UITapGestureRecognizer* tap;
@property (strong) UITapGestureRecognizer* tapInsideEndingTimeViewCell;

@end

#pragma mark -
#pragma mark Flipside View Controller Delegate Protocol

@protocol FlipsideViewControllerDelegate

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (void)eventDidUpdate:(NSUInteger)eventIdentifier;
- (void)eventDidMove:(NSUInteger)sourceIndex to:(NSUInteger)destinationIndex;
- (void)eventWasRemoved:(NSUInteger)eventIdentifier;
- (void)eventDisplayMethodUpdated;
- (void)dayOverTimeUpdated;

@end

