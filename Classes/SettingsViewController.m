//
//  InfoViewController.m
//  Doing Time
//
//  Created by Randall Wood on 28/11/2013.
//
//  Copyright 2013-2014, 2020 Randall Wood DBA Alexandria Software
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

#import "SettingsViewController.h"
#import "Doing_TimeAppDelegate.h"

#define IAPSection 0
#define SupportSection 1

@interface SettingsViewController ()

#pragma mark - Table view data source
- (BOOL)hasUsableAppStoreTableSection;

@property BOOL showErrorAlert;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.appDelegate = (Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate;
        self.showErrorAlert = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.hasUsableAppStoreTableSection) {
		return 2;
	}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == IAPSection && !self.hasUsableAppStoreTableSection) {
		section++;
	}
	switch (section) {
		case SupportSection:
			return 2;
			break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	if (indexPath.section == IAPSection && !self.hasUsableAppStoreTableSection) {
		section = indexPath.section + 1;
	}
	NSUInteger eventsCount = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
    
	UITableViewCell *cell;
	if (section == SupportSection || (indexPath.section != section) || (indexPath.section == IAPSection && indexPath.row == eventsCount + 1)) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"BasicDisclosureCell"];
	} else if (section == IAPSection && indexPath.row == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
	}
    
	cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
	
    switch (section) {
		case SupportSection:
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Send Feedback", @"Label for link to provide application feedback");
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"About Doing Time", @"Label for link for information about the application");
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Support", @"Label for link to support resources");
					break;
				default:
					break;
			}
			break;
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == IAPSection && !self.hasUsableAppStoreTableSection) {
		section++;
	}
	switch (section) {
		case IAPSection:
			return NSLocalizedString(@"Available Upgrades", @"Heading for list of available in-app purchases");
			break;
		case SupportSection:
			return NSLocalizedString(@"About Doing Time", @"Heading for list of elements about the app (help, credits, feedback, etc)");
			break;
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == IAPSection && !self.hasUsableAppStoreTableSection) {
		section++;
	}
	switch (section) {
		case SupportSection:
            return [NSString localizedStringWithFormat:NSLocalizedString(@"%@ version %@ (%@)", @"About view version footer"),
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
			break;
	}
	return nil;
}

- (BOOL)hasUsableAppStoreTableSection {
    // since IAP is disabled in 2.0, this should always be NO
    return NO;
    // should be true if products are available to purchase && IAP is allowed && can get non-empty list of products
//    return (![self.appDelegate.appStore hasTransactionsForAllProducts] &&
//            (self.appDelegate.appStore.canMakePayments &&
//            self.appDelegate.appStore.validProducts.count != 0));
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MFMailComposeViewController* mailController;
	NSUInteger section = indexPath.section;
	if (!self.hasUsableAppStoreTableSection) {
		section = indexPath.section + 1;
	}
    NSLog(@"Showing section %lu", (unsigned long)section);
	self.showErrorAlert = YES;
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	switch (section) {
		case SupportSection: // About
			switch (indexPath.row) {
				case 0:
					if (YES) { // Why can't I allocate an object after following a path in a switch?
                        mailController = [[MFMailComposeViewController alloc] init];
                        mailController.mailComposeDelegate = self;
                        [mailController setSubject:[NSString localizedStringWithFormat:NSLocalizedString(@"Doing Time %@ (%@) Feedback", @"Email subject for application feedback"),
                                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
                                                    ]];
                        [mailController setToRecipients:@[@"Support@AlexandriaSoftware.com"]];
                        [mailController setMessageBody:@"" isHTML:NO];
                        if (mailController) {
                            mailController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
                            [self presentViewController:mailController animated:YES completion:nil];
                        }
                    }
					break;
				case 1:
                    // DO NOTHING - let the segue work
					break;
			}
			break;
	}
}

 #pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender isEqual:self.navigationItem.leftBarButtonItem]) {
        NSLog(@"WTF");
        return YES;
    }
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    NSInteger section = indexPath.section;
    if (!self.hasUsableAppStoreTableSection) {
        section++;
    }
    switch (section) {
        case IAPSection:
            return NO;
            break;
        case SupportSection:
            switch (indexPath.row) {
                case 0:
                    return NO;
                    break;
                default:
                    break;
            }
            break;
    }
    return YES;
}

#pragma mark - Mail composition delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
