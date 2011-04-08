//
//  FlipsideViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "TitleEditorViewController.h"
#import "NSDate+Additions.h"

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController <TitleEditorViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
	id <FlipsideViewControllerDelegate> delegate;
	UITableView* _tableView;
	UIDatePicker* _datePicker;
	BOOL settingStartDate;
	BOOL settingEndDate;
}

- (IBAction)done:(id)sender;
- (void)clearDatePicker;

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableView* tableView;
@property (nonatomic, assign) IBOutlet UIDatePicker* datePicker;
@property BOOL settingStartDate;
@property BOOL settingEndDate;

@end


@protocol FlipsideViewControllerDelegate

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;

@end

