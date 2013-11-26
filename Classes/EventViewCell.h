//
//  EventViewCell.h
//  Doing Time
//
//  Created by Randall Wood on 24/11/2013.
//
//

#import <UIKit/UIKit.h>

@class PieChartView;

@interface EventViewCell : UITableViewCell

@property (weak) IBOutlet UILabel *title;
@property (weak) IBOutlet UILabel *dates;
@property (weak) IBOutlet UILabel *stats;
@property (weak) IBOutlet PieChartView *pieChart;

@end
