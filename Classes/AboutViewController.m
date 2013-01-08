//
//  AboutViewController.m
//  Doing Time
//
//  Created by Randall Wood on 18/4/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize logoCell = _logoCell;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = NSLocalizedString(@"About Doing Time", @"");
    self.accessibilityLabel = self.title;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark -
#pragma mark Table view data source

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
			return 1;
			break;
		default:
			return 0;
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.isAccessibilityElement = YES;
	switch (indexPath.section) {
		case 0:
			return self.logoCell;
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Web", @"Short term for World Wide Web");
					cell.detailTextLabel.text = @"alexandriasoftware.com";
                    cell.accessibilityLabel = NSLocalizedString(@"On the web at alexandriasoftware.com", @"AccessibilityLabel for Web");
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"Twitter", @"Short term for Twitter");
					cell.detailTextLabel.text = @"@alexandriasw";
                    cell.accessibilityLabel = NSLocalizedString(@"On Twitter at alexandriasw", @"AccessibilityLabel for Twitter");
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Facebook", @"Short term for Facebook");
					cell.detailTextLabel.text = NSLocalizedString(@"Like us!", @"Facebook \"Like us!\" tagline");
                    cell.accessibilityLabel = NSLocalizedString(@"Like us on Facebook!", @"AccessibilityLabel for Facebook");
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"Support", @"Short title for support resources");
					cell.detailTextLabel.text = NSLocalizedString(@"Contact Us", @"Short invitation to send us a message");
                    cell.accessibilityLabel = NSLocalizedString(@"Contact us via our website.", @"AccessibilityLabel for Contact Us");
					break;
				default:
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Dain Kaplan";
					cell.detailTextLabel.text = @"Chartreuse";
                    cell.accessibilityLabel = NSLocalizedString(@"We thank Dain Kaplan for Chartreuse.", @"AccessibilityLabel for Chartreuse (thanks)");
					break;
				default:
					break;
			}
		default:
			break;
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == ([self numberOfSectionsInTableView:tableView] - 1)) {
        return [NSString localizedStringWithFormat:NSLocalizedString(@"%@ %@ (%@)", @"About view version footer"),
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    }
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

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

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

@end

