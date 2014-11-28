//
//  EventViewController.h
//  Doing Time
//
//  Created by Randall Wood on 2/3/2011.
//
//  Copyright (c) 2011-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
