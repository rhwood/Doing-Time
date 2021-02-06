//
//  AboutViewController.m
//  Doing Time
//
//  Created by Randall Wood on 18/4/2011.
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

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize logoCell = _logoCell;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = NSLocalizedString(@"About Doing Time", @"");
    self.accessibilityLabel = self.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITableViewHeaderFooterView *footer = [self.tableView footerViewForSection:(self.tableView.numberOfSections - 1)];
    footer.detailTextLabel.text = nil;
    footer.textLabel.text = [NSString localizedStringWithFormat:footer.textLabel.text,
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow].selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 4;
			break;
		case 2:
			return 2;
			break;
		default:
			return 0;
			break;
	}
    return 0;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == ([self numberOfSectionsInTableView:tableView] - 1)) {
        return [NSString localizedStringWithFormat:NSLocalizedString(@"%@ version %@ (%@) - Should not see", @"About view version footer"),
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    }
    return nil;
}
*/
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0: // AXSW site from Logo
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/fufMuq"]];
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0: // AXSW site from Text
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/icgDcu"]];
					break;
				case 1: // Twitter
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/f4dzGc"]];
					break;
				case 2: // Facebook like
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/eaDeKF"]];
					break;
				case 3: // Contact Site
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/fO5256"]];
					break;
				default:
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0: // Chartreuse site
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/fuCJn9"]];
					break;
                case 1: // Glyphish site
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/11IOfOC"]];
                    break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 72.0;
	}
	return tableView.rowHeight;
}

@end

