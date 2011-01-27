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
}

- (IBAction)done:(id)sender;

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITableView* tableView;
@property (nonatomic, assign) IBOutlet UIDatePicker* datePicker;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

