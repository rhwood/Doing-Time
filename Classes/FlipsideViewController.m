//
//  FlipsideViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import "EventSettingsViewController.h"
#import "Doing_TimeAppDelegate.h"
#import "AppStoreDelegate.h"
#import <StoreKit/StoreKit.h>

@implementation FlipsideViewController

@synthesize delegate;
@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize showErrorAlert;
@synthesize endingTimeViewCellIndexPath = _endingTimeViewCellIndexPath;
@synthesize detailTextLabelColor = _detailTextLabelColor;
@synthesize appDelegate = _appDelegate;
@synthesize waitingView = _waitingView;
@synthesize waitingIndicator = _waitingIndicator;
@synthesize waitingText = _waitingText;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.appDelegate = [UIApplication sharedApplication].delegate;

	self.navigationItem.title = @"Settings";
	// insert the Done button
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Doing Time"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(done:)];
	// insert the Edit button
	[self setEditButton];
	
	[self.navigationController setNavigationBarHidden:NO];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.showErrorAlert = YES;
	self.endingTimeViewCellIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
	// set the detailTextLabel.textColor since its not a built in color
	self.detailTextLabelColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
	// App Store
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreDidReceiveProductsList
													  object:self.appDelegate.appStoreDelegate
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self.tableView reloadData];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreNewContentShouldBeProvided
													  object:self.appDelegate.appStoreDelegate
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self hidePurchaseActivity:YES];
													  [self.tableView reloadData];
													  [self setEditButton];
												  }];
}

- (void)viewDidAppear:(BOOL)animated {
	if (![[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[self addEvent];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSUInteger eventsCount = [self.tableView numberOfRowsInSection:0];
	if (eventsCount == [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[delegate eventDidUpdate:eventsCount];
	}
	[self.tableView reloadData];
}

- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (void)setEditButton {
	if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		self.navigationItem.rightBarButtonItem = [self editButtonItem];
	} else {
		self.navigationItem.rightBarButtonItem = nil;
	}
	self.editing = NO;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Events

- (void)addEvent {
	EventSettingsViewController *controller = [[EventSettingsViewController alloc] initWithEventIndex:[[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (![self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		return 3; // Disable the support elements for 1.2
	}
	return 2; // Disable the support elements for 1.2
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 2 &&
		[self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		section++;
	}
	switch (section) {
		case 0: // Activity
			if (![self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
				return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
			}
			return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count] + 1;
			break;
		case 1: // Display
			return 2; // For 1.1 percentages and hour the day is complete
			break;
		case 2: // Store
			return [self.appDelegate.appStoreDelegate.products count];
			break;
		case 3: // Support
			return 3;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	NSUInteger section = indexPath.section;
	if (indexPath.section == 2 &&
		[self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		section = indexPath.section + 1;
	}
	NSUInteger eventsCount = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if (section == 3 || (indexPath.section != section) || (indexPath.section == 0 && indexPath.row == eventsCount + 1)) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		} else if (section == 0 || section == 2) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		} else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
    }
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
    switch (section) {
		case 0: // Events
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			if (indexPath.row == eventsCount) {
				if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
					cell.textLabel.text = @"Add Event";
				}
			} else if (indexPath.row < eventsCount) {
				NSDictionary* event = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:indexPath.row];
				cell.textLabel.text = [event objectForKey:titleKey];
				cell.detailTextLabel.text = [NSString localizedStringWithFormat:@"%@ to %@",
											 [NSDateFormatter localizedStringFromDate:[event objectForKey:startKey]
																			dateStyle:NSDateFormatterMediumStyle
																			timeStyle:NSDateFormatterNoStyle],
											 [NSDateFormatter localizedStringFromDate:[event objectForKey:endKey]
																			dateStyle:NSDateFormatterMediumStyle
																			timeStyle:NSDateFormatterNoStyle]];
			}
			break;
		case 1: // Display
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Show Percentages";
					cell.detailTextLabel.text = @"";
					if ([[NSUserDefaults standardUserDefaults] boolForKey:showPercentageKey]) {
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					} else {
						cell.accessoryType = UITableViewCellAccessoryNone;
					}
					break;
				case 1:
					cell.textLabel.text = @"Day ends at";
					if ([[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]) {
						cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]
																					dateStyle:NSDateFormatterNoStyle
																					timeStyle:NSDateFormatterShortStyle];
					}
					break;
				default:
					break;
			}
			break;
		case 2: // Store
			if (self.appDelegate.appStoreDelegate.canMakePayments &&
				[self.appDelegate.appStoreDelegate.products count]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				SKProduct *product = [self.appDelegate.appStoreDelegate.products objectAtIndex:indexPath.row];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[numberFormatter setLocale:product.priceLocale];
				cell.textLabel.text = product.localizedTitle;
				cell.detailTextLabel.text = [NSString localizedStringWithFormat:@"%@ for %@", 
											 product.localizedDescription,
											 [numberFormatter stringFromNumber:product.price]];
			}
			break;
		case 3: // Support
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Tutorial";
					break;
				case 1:
					cell.textLabel.text = @"Support";
					break;
				case 2:
					cell.textLabel.text = @"About Doing Time";
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
	if (section == 2 &&
		[self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		section++;
	}
	switch (section) {
		case 0:
			return @"Events";
			break;
		case 1:
			return @"Display";
			break;
		case 2:
			return @"Available Upgrades";
			break;
		case 3:
			return @"Help";
			break;
		default:
			break;
	}
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row <= [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		return YES;
	}
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row < [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		return YES;
	}
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
		[events removeObjectAtIndex:indexPath.row];
		[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[delegate eventWasRemoved:indexPath.row];
	} else {
		[self addEvent];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSMutableArray *events = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey]];
	NSDictionary *event = [[events objectAtIndex:sourceIndexPath.row] retain];
	[events removeObjectAtIndex:sourceIndexPath.row];
	[events insertObject:event atIndex:destinationIndexPath.row];
	[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[event release];
	[self.delegate eventDidMove:sourceIndexPath.row to:destinationIndexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2 &&
		[self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		section++;
	}
	switch (section) {
		case 0:
			break;
		case 1:
			break;
		case 2:
			// need to display the type of device
			if (!self.appDelegate.appStoreDelegate.canMakePayments) {
				return [NSString localizedStringWithFormat:@"In-App Purchases have been disabled on this %@.", @"device"];
			} else if (![self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier] &&
					![self.appDelegate.appStoreDelegate.products count]) {
					return @"Getting available upgrades...";
			}
			break;
		case 3:
			break;
	}
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	if (indexPath.section == 2 && 
		[self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
		indexPath.section + 1;
	}
	if (NSOrderedSame != [indexPath compare:self.endingTimeViewCellIndexPath]) {
		[self hideDatePicker:YES];
	}
	self.showErrorAlert = YES;
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	switch (section) {
		case 0: // Activity
			if (indexPath.row != [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
				// open eventSettingsViewController
				EventSettingsViewController *controller = [[EventSettingsViewController alloc] initWithEventIndex:indexPath.row];
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			} else if ([self.appDelegate.appStoreDelegate hasTransactionForProduct:multipleEventsProductIdentifier]) {
				// add empty event to array
				[self addEvent];
			}
			break;
		case 1: // Display
			switch (indexPath.row) {
				case 0:
					[[NSUserDefaults standardUserDefaults] setBool:(![[NSUserDefaults standardUserDefaults] 
																	  boolForKey:showPercentageKey])
															forKey:showPercentageKey];
					[self.tableView reloadData];
					[self.delegate eventDisplayMethodUpdated];
					break;
				case 1:
					if (self.datePicker.hidden) {
						self.datePicker.datePickerMode = UIDatePickerModeTime;
						[self hideDatePicker:NO];
						[self.datePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:dayOverKey]
										animated:YES];
					} else {
						[self hideDatePicker:YES];
						[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
					}
					break;
				default:
					break;
					
			}
			break;
		case 2: // Store
			if (self.appDelegate.appStoreDelegate.canMakePayments) {
				SKProduct *product = [self.appDelegate.appStoreDelegate.products objectAtIndex:indexPath.row];
				self.waitingText.text = [NSString localizedStringWithFormat:@"Getting %@...", product.localizedTitle];
				[self hidePurchaseActivity:NO];
				[[SKPaymentQueue defaultQueue] addPayment:
				 [SKPayment paymentWithProduct:
				  [self.appDelegate.appStoreDelegate.products objectAtIndex:indexPath.row]]];
			}
			break;
		case 3: // Help
			break;
		default:
			break;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row < [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
			return UITableViewCellEditingStyleDelete;
		} else {
			return UITableViewCellEditingStyleInsert;
		}
	}
	return UITableViewCellEditingStyleNone;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	NSUInteger eventsCount = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
	if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
		return [NSIndexPath indexPathForRow:eventsCount - 1 inSection:sourceIndexPath.section];
	}
	if (proposedDestinationIndexPath.row == eventsCount) {
		return [NSIndexPath indexPathForRow:eventsCount - 1 inSection:sourceIndexPath.section];
	}
	return proposedDestinationIndexPath;
}

#pragma mark -
#pragma mark Date Pickers

- (void)changeEndingTime:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:self.datePicker.date forKey:dayOverKey];
	[self.tableView cellForRowAtIndexPath:self.endingTimeViewCellIndexPath].detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date
																																  dateStyle:NSDateFormatterNoStyle
																																  timeStyle:NSDateFormatterShortStyle];
	[self.delegate eventDisplayMethodUpdated];
}

- (void)hideDatePicker:(BOOL)hidden {
	if (hidden != self.datePicker.hidden) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		if (!hidden) {
			self.datePicker.hidden = NO;
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height - self.datePicker.frame.size.height);
			self.datePicker.frame = CGRectOffset(self.datePicker.frame,
												 0,
												 -self.datePicker.frame.size.height - self.navigationController.navigationBar.frame.size.height);
		} else {
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height + self.datePicker.frame.size.height);
			self.datePicker.frame = CGRectOffset(self.datePicker.frame, 
												 0,
												 self.datePicker.frame.size.height + self.navigationController.navigationBar.frame.size.height);
		}
		[UIView commitAnimations];
		[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
		self.datePicker.hidden = hidden;
	}
}

#pragma mark -
#pragma mark Purchases

- (void)hidePurchaseActivity:(BOOL)hidden {
	if (hidden != self.waitingView.hidden) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		if (!hidden) {
			self.waitingView.hidden = NO;
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height - self.waitingView.frame.size.height);
			self.waitingView.frame = CGRectOffset(self.waitingView.frame,
												 0,
												 -self.waitingView.frame.size.height - self.navigationController.navigationBar.frame.size.height);
		} else {
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height + self.waitingView.frame.size.height);
			self.waitingView.frame = CGRectOffset(self.waitingView.frame, 
												 0,
												 self.waitingView.frame.size.height + self.navigationController.navigationBar.frame.size.height);
		}
		[UIView commitAnimations];
		[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
		self.waitingView.hidden = hidden;
	}
}

#pragma mark -
#pragma mark Action sheet view delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.tableView reloadData];
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
	[self.endingTimeViewCellIndexPath dealloc];
    [super dealloc];
}

@end
