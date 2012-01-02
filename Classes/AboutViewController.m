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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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
			return 2;
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
	switch (indexPath.section) {
		case 0:
			return self.logoCell;
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Web", @"Short term for World Wide Web");
					cell.detailTextLabel.text = @"alexandriasoftware.com";
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"Twitter", @"Short term for Twitter");
					cell.detailTextLabel.text = @"@alexandriasw";
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Facebook", @"Short term for Facebook");
					cell.detailTextLabel.text = NSLocalizedString(@"Like us!", @"Facebook \"Like us!\" tagline");
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"Support", @"Short title for support resources");
					cell.detailTextLabel.text = NSLocalizedString(@"Contact Us", @"Short invitation to send us a message");
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
					break;
				case 1:
					cell.textLabel.text = @"Andreas Linde";
					cell.detailTextLabel.text = @"QuincyKit";
					break;
				default:
					break;
			}
		default:
			break;
	}
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
				case 1: // QuincyKit
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://axsw.co/kEhPlB"]];
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

