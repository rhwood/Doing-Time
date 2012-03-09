//
//  FlipsideViewController.m
//  Doing Time
//
//  Created by Randall Wood on 27/12/2010.
//  Copyright 2010 Alexandria Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import "EventSettingsViewController.h"
#import "AboutViewController.h"
#import "Doing_TimeAppDelegate.h"
#import "AppStoreDelegate.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize tableView = _tableView;
@synthesize datePicker = _datePicker;
@synthesize showErrorAlert;
@synthesize endingTimeViewCellIndexPath = _endingTimeViewCellIndexPath;
@synthesize detailTextLabelColor = _detailTextLabelColor;
@synthesize appDelegate = _appDelegate;
@synthesize appStoreRequestFailed;
@synthesize activityIndicator = _activityIndicator;
@synthesize activityLabel = _activityLabel;
@synthesize activityView = _activityView;
@synthesize eventBeingUpdated;
@synthesize allowInAppPurchases;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allowInAppPurchases = YES; // set to NO until Lodsys patent litigation threat is lifted
    
	self.eventBeingUpdated = 0;
	
	self.appDelegate = (Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate;
	self.appStoreRequestFailed = NO;

	self.navigationItem.title = NSLocalizedString(@"Settings", @"Title for the settings panel of the applications");
	// insert the Done button
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Doing Time", @"")
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
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self.tableView reloadData];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreNewContentShouldBeProvided
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self hidePurchaseActivity:YES];
													  [self.tableView reloadData];
													  [self setEditButton];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreTransactionFailed
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  NSError *error = [[notification userInfo] objectForKey:AXAppStoreTransactionError];
													  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App Store Error", @"Title for alert indicating that there was an error accessing the app store")
																									   message:error.localizedDescription
																									  delegate:nil
																							 cancelButtonTitle:NSLocalizedString(@"OK", @"")
																							 otherButtonTitles:nil];
													  [alert show];
													  [self hidePurchaseActivity:YES];
													  [self.tableView reloadData];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreTransactionCancelled
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  [self hidePurchaseActivity:YES];
													  [self.tableView reloadData];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:AXAppStoreRequestFailed
													  object:self.appDelegate.appStore
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  self.appStoreRequestFailed = YES;
													  [self.tableView reloadData];
												  }];
	[self.appDelegate.appStore requestProductData:multipleEventsProductIdentifier ifHasTransaction:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	if (![[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[self addEvent];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if (eventBeingUpdated < [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[delegate eventDidUpdate:eventBeingUpdated];
		[self.tableView reloadData];
	}
}

- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (void)setEditButton {
	if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
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
	self.eventBeingUpdated = controller.index;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (![self.appDelegate.appStore hasTransactionsForAllProducts]) {
		return 4;
	}
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 2 &&
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section++;
	}
	switch (section) {
		case 0: // Activity
			if (![self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
				return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
			}
			return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count] + 1;
			break;
		case 1: // Display
			return 3;
			break;
		case 2: // Store
            if (self.allowInAppPurchases) {
                return [self.appDelegate.appStore.validProducts count];
            } else {
                return 0;
            }
			break;
		case 3: // Support
			return 2;
			break;
		default:
			break;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *DefaultCellIdentifier = @"DefaultCell";
	static NSString *SubtitleCellIdentifier = @"SubtitleCell";
	static NSString *Value1CellIdentifier = @"Value1Cell";
	NSUInteger section = indexPath.section;
	if (indexPath.section == 2 &&
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section = indexPath.section + 1;
	}
	NSUInteger eventsCount = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];

	UITableViewCell *cell;
	if (section == 3 || (indexPath.section != section) || (indexPath.section == 0 && indexPath.row == eventsCount + 1)) {
		cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCellIdentifier];
		}
	} else if (section == 1 && indexPath.row == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:Value1CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Value1CellIdentifier];
		}
    } else {
		cell = [tableView dequeueReusableCellWithIdentifier:SubtitleCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SubtitleCellIdentifier];
		}
	}

	cell.accessoryType = UITableViewCellAccessoryNone;
	
    switch (section) {
		case 0: // Events
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			if (indexPath.row == eventsCount) {
				if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
					cell.textLabel.text = NSLocalizedString(@"Add Event", @"Button to add another event to monitor. Button is in a table cell.");
                    cell.detailTextLabel.text = nil;
				}
			} else if (indexPath.row < eventsCount) {
				NSDictionary* event = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] objectAtIndex:indexPath.row];
				cell.textLabel.text = [event objectForKey:titleKey];
				cell.detailTextLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ to %@", @"The range from start to end"),
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
					cell.textLabel.text = NSLocalizedString(@"Percentages", @"Label for cell that includes checkmark to indicate that events are displayed with percentages");
					cell.detailTextLabel.text = @"";
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:showPercentageKey]];
                    [(UISwitch *)cell.accessoryView addTarget:self 
                                                       action:@selector(switchShowPercentages:)
                                             forControlEvents:UIControlEventValueChanged];
					break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Remaining Days Only", @"Label for cell that includes checkmark to indicate that events are displayed with the completed days count");
                    cell.detailTextLabel.text = @"";
                    // the text displayed to the user is the reverse of the setting
                    cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [(UISwitch *)cell.accessoryView setOn:![[NSUserDefaults standardUserDefaults] boolForKey:showCompletedDaysKey]];
                    [(UISwitch *)cell.accessoryView addTarget:self 
                                                       action:@selector(switchShowRemainingDays:)
                                             forControlEvents:UIControlEventValueChanged];
                    break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Day ends at", @"Label for cell that includes the hour of the day at which the day is considered past.");
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
			if (self.appDelegate.appStore.canMakePayments &&
				[self.appDelegate.appStore.validProducts count]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				SKProduct *product = [self.appDelegate.appStore.products objectForKey:[self.appDelegate.appStore.validProducts objectAtIndex:indexPath.row]];
				NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
				[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
				[numberFormatter setLocale:product.priceLocale];
				cell.textLabel.text = product.localizedTitle;
				cell.detailTextLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ for %@", @"String containing the description of an in-app purchase followed by the cost."), 
											 product.localizedDescription,
											 [numberFormatter stringFromNumber:product.price]];
			}
			break;
		case 3: // Support
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"Send Feedback", @"Label for link to provide application feedback");
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"About Doing Time", @"Label for link for information about the application");
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"Tutorial", @"Label for link to help content.");
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"Support", @"Label for link to support resources");
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
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section++;
	}
	switch (section) {
		case 0:
			return NSLocalizedString(@"Events", @"Heading for list of events");
			break;
		case 1:
			return NSLocalizedString(@"Display", @"Heading for settings affecting the display of events");
			break;
		case 2:
			return NSLocalizedString(@"Available Upgrades", @"Heading for list of available in-app purchases");
			break;
		case 3:
			return NSLocalizedString(@"About Doing Time", @"Heading for list of elements about the app (help, credits, feedback, etc)");
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
	NSDictionary *event = [events objectAtIndex:sourceIndexPath.row];
	[events removeObjectAtIndex:sourceIndexPath.row];
	[events insertObject:event atIndex:destinationIndexPath.row];
	[[NSUserDefaults standardUserDefaults] setObject:events forKey:eventsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.delegate eventDidMove:sourceIndexPath.row to:destinationIndexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2 &&
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section++;
	}
	switch (section) {
		case 0:
			break;
		case 1:
			break;
		case 2:
            if (self.allowInAppPurchases) {
                if (!self.appDelegate.appStore.canMakePayments) {
                    return [NSString localizedStringWithFormat:NSLocalizedString(@"In-App Purchases are disabled on this %@.", @"Notice that the user cannot purchase an available upgrade due to policy."), 
                            [UIDevice currentDevice].localizedModel];
                } else if (![self.appDelegate.appStore hasTransactionsForAllProducts] &&
                           ![self.appDelegate.appStore hasDataForAnyProducts]) {
                    if ([self.appDelegate.appStore.openRequests count]) {
                        return NSLocalizedString(@"Getting available upgrades...", @"Notice that the application is getting the list of available in-app purchases.");
                    } else {
                        return NSLocalizedString(@"Unable to get available upgrades.", @"Notice that the application cannot get the list of available in-app purchases.");
                    }
                }
            } else {
                return NSLocalizedString(@"In-App Purchases have been disabled due to threats of patent litigation.", @"Notice that In-App Purchases are disabled.");
            }
			break;
		case 3:
			break;
	}
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MFMailComposeViewController* mailController;
	NSUInteger section = indexPath.section;
	if (indexPath.section >= 2 && 
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section = indexPath.section + 1;
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
				eventBeingUpdated = controller.index;
			} else if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
				// add empty event to array
				[self addEvent];
			}
			break;
		case 1: // Display
			switch (indexPath.row) {
				case 0:
                    // showPercentageKey setting is a UISwitch
					break;
                case 1:
                    // showCompletedDaysKey setting is a UISwitch
                    break;
                case 2:
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
			if (self.appDelegate.appStore.canMakePayments) {
				SKProduct *product = [self.appDelegate.appStore.products objectForKey:[[self.appDelegate.appStore.products allKeys] objectAtIndex:indexPath.row]];
				self.activityLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Getting %@...", @"Label indicating that app is getting an in-app purchase (with %@ as the title)"), product.localizedTitle];
				[self hidePurchaseActivity:NO];
				[self.appDelegate.appStore queuePaymentForProduct:product];
			}
			break;
		case 3: // Help
			switch (indexPath.row) {
				case 0:
					if (YES) { // Why can't I allocate an object after following a path in a switch?
                        mailController = [[MFMailComposeViewController alloc] init];
                        mailController.mailComposeDelegate = self;
                        [mailController setSubject:[NSString localizedStringWithFormat:NSLocalizedString(@"Doing Time %@ Feedback", @"Email subject for application feedback"),
                                                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
                        [mailController setToRecipients:[NSArray arrayWithObject:@"Support@AlexandriaSoftware.com"]];
                        [mailController setMessageBody:@"" isHTML:NO];
                        if (mailController) {
                            [self presentModalViewController:mailController animated:YES];
                        }
                    }
					break;
				case 1:
					[self.navigationController pushViewController:[[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil] animated:YES];
					break;
				default:
					break;
			}
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
	[self.delegate dayOverTimeUpdated];
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

#pragma mark - Display Settings

- (void)switchShowPercentages:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[(UISwitch *)sender isOn] forKey:showPercentageKey];
    [self.delegate eventDisplayMethodUpdated];
}

- (void)switchShowRemainingDays:(id)sender {
    // inverse of switch since setting is displayed using opposite language
    [[NSUserDefaults standardUserDefaults] setBool:![(UISwitch *)sender isOn] forKey:showCompletedDaysKey];
    [self.delegate eventDisplayMethodUpdated];
}

#pragma mark -
#pragma mark Purchases

- (void)hidePurchaseActivity:(BOOL)hidden {
	if (hidden != self.activityView.hidden) {
		[UIView beginAnimations:@"animateDisplayPager" context:NULL];
		if (!hidden) {
			self.activityView.hidden = NO;
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height - self.activityView.frame.size.height);
			self.activityView.frame = CGRectOffset(self.activityView.frame,
												 0,
												 -self.activityView.frame.size.height - self.navigationController.navigationBar.frame.size.height);
		} else {
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height + self.activityView.frame.size.height);
			self.activityView.frame = CGRectOffset(self.activityView.frame, 
												 0,
												 self.activityView.frame.size.height + self.navigationController.navigationBar.frame.size.height);
		}
		[UIView commitAnimations];
		[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
		self.activityView.hidden = hidden;
	}
}

#pragma mark -
#pragma mark Mail composition delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.tableView = nil;
	self.datePicker = nil;
	self.activityLabel = nil;
	self.activityView = nil;
}

@end
