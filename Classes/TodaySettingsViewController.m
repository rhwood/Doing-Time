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

- (id)initWithTodaySetting:(TodayIs)setting {
    if ((self = [super initWithNibName:@"TodaySettingsView" bundle:nil])) {
        self.setting = setting;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// navigation items
	self.navigationItem.title = NSLocalizedString(@"Today Is",@"Title for TodaySettingsView");
    self.accessibilityLabel = self.navigationItem.title;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:todayIsKey object:self userInfo:@{todayIsKey: @(self.setting)}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Value1Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == self.setting) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    switch (indexPath.row) {
        case todayIsOver:
            cell.textLabel.text = NSLocalizedString(@"Complete", @"Label for handling today as if it is already over");
            cell.detailTextLabel.text = NSLocalizedString(@"Count today as if it is over", @"Explanitory label for handling today as if it is already over");
            break;
        case todayIsNotCounted:
            cell.textLabel.text = NSLocalizedString(@"Uncounted", @"Label for handling today as if it is neither remaining or over");
            cell.detailTextLabel.text = NSLocalizedString(@"Today is neither remaining nor over", @"Explanitory label for handling today as if it is already over");
            break;
        case todayIsRemaining:
            cell.textLabel.text = NSLocalizedString(@"Remaining", @"Label for handling today as if it is not yet over");
            cell.detailTextLabel.text = NSLocalizedString(@"Include today in remaining days", @"Explanitory label for handling today as if it is not yet over");
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.setting = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
