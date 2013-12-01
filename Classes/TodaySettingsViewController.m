//
//  TodaySettingViewController.m
//  Doing Time
//
//  Created by Randall Wood on 24/1/2013.
//
//

#import "TodaySettingsViewController.h"

@interface TodaySettingsViewController ()

@end

@implementation TodaySettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accessibilityLabel = self.navigationItem.title;
}

- (void)setSetting:(TodayIs)setting {
    _setting = setting;
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:todayIsKey object:self userInfo:@{todayIsKey: @(self.setting)}];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == self.setting) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _setting = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
