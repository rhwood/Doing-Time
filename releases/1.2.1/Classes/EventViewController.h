//
//  EventViewController.h
//  Doing Time
//
//  Created by Randall Wood on 2/3/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieChartView;
@class MainViewController;

@interface EventViewController : UIViewController {
	PieChartView *_pieChart;
	
	UILabel *_daysComplete;
	UILabel *_daysLeft;
	UILabel *_eventTitle;
	UIView *_controls;
	UIView *_piePlate;
	MainViewController *_mainView;

	NSUInteger _eventID;
}

- (id)initWithEvent:(NSUInteger)event;
- (IBAction)showInfo:(id)sender;
- (void)setPieChartValues;

@property (nonatomic, retain) IBOutlet PieChartView *pieChart;
@property (nonatomic, retain) IBOutlet UILabel *daysComplete;
@property (nonatomic, retain) IBOutlet UILabel *daysLeft;
@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
@property (nonatomic, retain) IBOutlet UIView *controls;
@property (nonatomic, retain) IBOutlet UIView *piePlate;
@property (nonatomic, retain) IBOutlet MainViewController *mainView;
@property NSUInteger eventID;

@end
