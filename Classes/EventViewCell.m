//
//  EventViewCell.m
//  Doing Time
//
//  Created by Randall Wood on 24/11/2013.
//
//

#import "EventViewCell.h"
#import "PieChartView.h"

@implementation EventViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
