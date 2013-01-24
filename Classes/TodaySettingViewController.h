//
//  TodaySettingViewController.h
//  Doing Time
//
//  Created by Randall Wood on 24/1/2013.
//
//

#import <UIKit/UIKit.h>

@interface TodaySettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Properties

@property (nonatomic, strong) IBOutlet UITableView* tableView;

@end
