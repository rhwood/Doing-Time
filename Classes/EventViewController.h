//
//  EventViewController.h
//  Doing Time
//
//  Created by Randall Wood on 2/3/2011.
//
//  Copyright 2011-2014, 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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

+ (float)brightnessForColor:(UIColor *)color;

- (id)initWithEvent:(NSUInteger)event;
- (void)redrawEvent:(BOOL)forceRedraw;
- (IBAction)showSettings:(id)sender;
- (IBAction)showInfo:(id)sender;
- (BOOL)setPieChartValues:(BOOL)forceRedraw;

@property (nonatomic, strong) IBOutlet PieChartView *pieChart;
@property (nonatomic, strong) IBOutlet UILabel *daysComplete;
@property (nonatomic, strong) IBOutlet UILabel *daysLeft;
@property (nonatomic, strong) IBOutlet UILabel *dateRange;
@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (nonatomic, strong) IBOutlet UIView *controls;
@property (nonatomic, strong) IBOutlet UIView *piePlate;
@property (nonatomic, strong) IBOutlet UIButton *settings;
@property (strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) IBOutlet MainViewController *mainView;
@property NSUInteger eventID;
@property BOOL showingAlert;
@property (nonatomic, strong) NSDictionary *event;
@property (nonatomic, strong) NSDictionary *oldEvent;
@property (nonatomic, strong) NSCalendar *calendar;
@property (readonly) float backgroundBrightness;

@end
