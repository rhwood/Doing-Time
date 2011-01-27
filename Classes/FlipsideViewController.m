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

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.datePicker.hidden = YES;
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
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
    if (indexPath.section == 0) {
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
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
	if (section == 0) {
		return @"Activity";
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"Set the start and end dates for the activity.";
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
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				// need to allow editing here
				// allow editing by placing a text field in the cell when selected
				self.datePicker.hidden = YES;
				[self.datePicker setDate:[NSDate date] animated:NO];
				TitleEditorViewController *controller = [[TitleEditorViewController alloc] initWithNibName:@"TitleEditorView"
																									bundle:nil];
				controller.delegate = self;
				controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				[self presentModalViewController:controller animated:NO];
				[controller release];
				break;
			case 1:
				self.datePicker.hidden = NO;
				[self.datePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"Start Date"]
								animated:YES];
				[self.datePicker removeTarget:self
									   action:@selector(changeEndDate:)
							 forControlEvents:UIControlEventValueChanged];
				[self.datePicker addTarget:self
									action:@selector(changeStartDate:)
						  forControlEvents:UIControlEventValueChanged];
				break;
			case 2:
				self.datePicker.hidden = NO;
				[self.datePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"End Date"] 
								animated:YES];
				[self.datePicker removeTarget:self
									   action:@selector(changeStartDate:)
							 forControlEvents:UIControlEventValueChanged];
				[self.datePicker addTarget:self
									action:@selector(changeEndDate:)
						  forControlEvents:UIControlEventValueChanged];
				break;
			default:
				break;
		}
	}
}

- (void)changeStartDate:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate midnightForDate:self.datePicker.date] forKey:@"Start Date"];
	[self.tableView reloadData];
}

- (void)changeEndDate:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate midnightForDate:self.datePicker.date] forKey:@"End Date"];	
	[self.tableView reloadData];
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
