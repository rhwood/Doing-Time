//
//  TodaySettingViewController.h
//  Doing Time
//
//  Created by Randall Wood on 24/1/2013.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface TodaySettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithTodaySetting:(TodayIs)setting;

#pragma mark - Properties

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic) TodayIs setting;

@end
