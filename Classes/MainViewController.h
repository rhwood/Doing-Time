//
//  MainViewController.h
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import <iAd/iAd.h>

@class PieChartView;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, ADBannerViewDelegate> {
	
	PieChartView *_pieChart;
	UILabel *_daysComplete;
	UILabel *_daysLeft;
	UILabel *_eventTitle;
	UIView *_controls;
	UIView *_piePlate;
	BOOL _displayBanner;
	BOOL _bannerIsVisible;
}

- (void)setPieChartValues;

- (IBAction)showInfo:(id)sender;

@property (nonatomic, retain) IBOutlet PieChartView *pieChart;
@property (nonatomic, retain) IBOutlet UILabel *daysComplete;
@property (nonatomic, retain) IBOutlet UILabel *daysLeft;
@property (nonatomic, retain) IBOutlet UILabel *eventTitle;
@property (nonatomic, retain) IBOutlet UIView *controls;
@property (nonatomic, retain) IBOutlet UIView *piePlate;
@property BOOL bannerIsVisible;
@property BOOL displayBanner;

@end
