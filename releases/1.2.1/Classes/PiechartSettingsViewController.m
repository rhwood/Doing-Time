//
//  FlipsideViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize settingStartDate;
@synthesize settingEndDate;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	[self clearDatePicker];
}


- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0: // Activity
			return 3;
			break;
		case 1: // Display
			return 2;
		default:
			break;
	}
	if (section == 0) {
		return 3;
	} else {
		return 2;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
    switch (indexPath.section) {
		case 0: // Activity
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Title";
					cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Title"];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = @"Start Date";
					cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"]
																			   dateStyle:NSDateFormatterLongStyle
																			   timeStyle:NSDateFormatterNoStyle];
					break;
				case 2:
					cell.textLabel.text = @"End Date";
					cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"]
																			   dateStyle:NSDateFormatterLongStyle
																			   timeStyle:NSDateFormatterNoStyle];
					break;
				default:
					break;
			}
			break;
		case 1: // Display
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Show Percentages";
					if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Show Percentages"]) {
						cell.detailTextLabel.text = @"Enabled";
					} else {
						cell.detailTextLabel.text = @"Disabled";
					}
					break;
				case 1:
					cell.textLabel.text = @"Hide Advertisements";
					if ([[NSUserDefaults standardUserDefaults] dataForKey:@"adFreeTransaction"]) {
						if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Hide Advertisements"]) {
							cell.detailTextLabel.text = @"Enabled";
						} else {
							cell.detailTextLabel.text = @"Disabled";
						}
					} else {
						cell.detailTextLabel.text = @"Purchase";
					}
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Activity";
			break;
		case 1:
			return @"Display";
			break;
		default:
			break;
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Set the start and end dates.";
			break;
		case 1:
			return nil;
			break;
	}
	return nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0: // Activity
			switch (indexPath.row) {
				case 0:
					// need to allow editing here
					// allow editing by placing a text field in the cell when selected
					[self clearDatePicker];
					TitleEditorViewController *controller = [[TitleEditorViewController alloc] initWithNibName:@"TitleEditorView"
																										bundle:nil];
					controller.delegate = self;
					controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
					[self presentModalViewController:controller animated:NO];
					[controller release];
					break;
				case 1:
					if (!self.settingStartDate) {
						self.settingEndDate = NO;
						self.datePicker.hidden = NO;
						[self.datePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"]
										animated:YES];
						[self.datePicker removeTarget:self
											   action:@selector(changeEndDate:)
									 forControlEvents:UIControlEventValueChanged];
						[self.datePicker addTarget:self
											action:@selector(changeStartDate:)
								  forControlEvents:UIControlEventValueChanged];
					} else {
						self.datePicker.hidden = YES;
						[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
					}
					self.settingStartDate = !self.settingStartDate;
					break;
				case 2:
					if (!self.settingEndDate) {
						self.settingStartDate = NO;
						self.datePicker.hidden = NO;
						[self.datePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"] 
										animated:YES];
						[self.datePicker removeTarget:self
											   action:@selector(changeStartDate:)
									 forControlEvents:UIControlEventValueChanged];
						[self.datePicker addTarget:self
											action:@selector(changeEndDate:)
								  forControlEvents:UIControlEventValueChanged];					
					} else {
						self.datePicker.hidden = YES;
						[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
					}
					self.settingEndDate = !self.settingEndDate;
					break;
				default:
					break;
			}
			break;
		case 1: // Display
			[self clearDatePicker];
			switch (indexPath.row) {
				case 0:
					[[NSUserDefaults standardUserDefaults] setBool:(![[NSUserDefaults standardUserDefaults] 
																	  boolForKey:@"Show Percentages"])
															forKey:@"Show Percentages"];
					[self.tableView reloadData];
				case 1:
					if ([[NSUserDefaults standardUserDefaults] dataForKey:@"adFreeTransaction"]) {
						[[NSUserDefaults standardUserDefaults] setBool:(![[NSUserDefaults standardUserDefaults]
																		boolForKey:@"Hide Advertisements"])
																forKey:@"Hide Advertisements"];
						[self.tableView reloadData];
					} else {
						
					}
				default:
					break;
					
			}
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Date Pickers

- (void)changeStartDate:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate midnightForDate:self.datePicker.date] forKey:@"Start Date"];
	[self.tableView reloadData];
}

- (void)changeEndDate:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate midnightForDate:self.datePicker.date] forKey:@"End Date"];	
	[self.tableView reloadData];
}

- (void)clearDatePicker {
	self.datePicker.hidden = YES;
	[self.datePicker setDate:[NSDate date] animated:NO];
	self.settingStartDate = NO;
	self.settingEndDate = NO;
}

#pragma mark -
#pragma mark Title editor delegate

- (void)titleEditorViewControllerDidFinish:(TitleEditorViewController *)controller {
	[self.tableView reloadData];
	[self dismissModalViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
