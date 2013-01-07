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
- (void)redrawEvent:(BOOL)forceRedraw;
- (IBAction)showInfo:(id)sender;
- (BOOL)setPieChartValues:(BOOL)forceRedraw;

@property (nonatomic, strong) IBOutlet PieChartView *pieChart;
@property (nonatomic, strong) IBOutlet UILabel *daysComplete;
@property (nonatomic, strong) IBOutlet UILabel *daysLeft;
@property (nonatomic, strong) IBOutlet UILabel *dateRange;
@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (nonatomic, strong) IBOutlet UIView *controls;
@property (nonatomic, strong) IBOutlet UIView *piePlate;
@property (nonatomic, strong) IBOutlet MainViewController *mainView;
@property NSUInteger eventID;
@property (nonatomic, strong) NSDictionary *oldEvent;

@end
