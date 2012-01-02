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
	NSInteger _oldComplete;
	NSInteger _oldLeft;
	NSInteger _oldTotal;
	NSString *_oldTitle;
}

- (id)initWithEvent:(NSUInteger)event;
- (void)redrawEvent:(BOOL)forceRedraw;
- (IBAction)showInfo:(id)sender;
- (BOOL)setPieChartValues:(BOOL)forceRedraw;

@property (nonatomic, retain) IBOutlet PieChartView *pieChart;
@property (nonatomic, retain) IBOutlet UILabel *daysComplete;
@property (nonatomic, retain) IBOutlet UILabel *daysLeft;
@property (nonatomic, retain) IBOutlet UILabel *dateRange;
@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
@property (nonatomic, retain) IBOutlet UIView *controls;
@property (nonatomic, retain) IBOutlet UIView *piePlate;
@property (nonatomic, retain) IBOutlet MainViewController *mainView;
@property NSUInteger eventID;
@property NSInteger oldComplete;
@property NSInteger oldLeft;
@property NSInteger oldTotal;
@property (nonatomic, retain) NSString *oldTitle;

@end
