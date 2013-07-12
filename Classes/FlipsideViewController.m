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
@synthesize showErrorAlert;
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
    
	self.eventBeingUpdated = INT_MAX;
	
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
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.showErrorAlert = YES;
	self.endingTimeViewCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
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
    [super viewDidAppear:animated];
	if (![[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[self addEvent];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (eventBeingUpdated < [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
		[delegate eventDidUpdate:eventBeingUpdated];
		[self.tableView reloadData];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow].selectionStyle = UITableViewCellSelectionStyleNone;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

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

- (void)editEvent:(NSUInteger)eventID {
    EventSettingsViewController *controller = [[EventSettingsViewController alloc] initWithEventIndex:eventID];
    [self.navigationController pushViewController:controller animated:YES];
    self.eventBeingUpdated = controller.index;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (![self.appDelegate.appStore hasTransactionsForAllProducts] && self.appDelegate.appStore.canMakePayments) {
		return 3;
	}
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 1 &&
		([self.appDelegate.appStore hasTransactionsForAllProducts] || !self.appDelegate.appStore.canMakePayments)) {
		section++;
	}
	switch (section) {
		case 0: // Activity
			if (![self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
				return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];
			}
			return [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count] + 1;
			break;
		case 1: // Store
            if (self.allowInAppPurchases) {
                return self.appDelegate.appStore.validProducts.count + 1;
            } else {
                return 0;
            }
			break;
		case 2: // Support
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
	if (indexPath.section == 1 &&
		([self.appDelegate.appStore hasTransactionsForAllProducts] || !self.appDelegate.appStore.canMakePayments)) {
		section = indexPath.section + 1;
	}
	NSUInteger eventsCount = [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count];

	UITableViewCell *cell;
	if (section == 2 || (indexPath.section != section) || (indexPath.section == 0 && indexPath.row == eventsCount + 1)) {
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
    cell.accessoryView = nil;
	
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
		case 1: // Store
			if (self.appDelegate.appStore.canMakePayments) {
                if (indexPath.row < self.appDelegate.appStore.validProducts.count) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    SKProduct *product = [self.appDelegate.appStore.products objectForKey:[self.appDelegate.appStore.validProducts objectAtIndex:indexPath.row]];
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [numberFormatter setLocale:product.priceLocale];
                    cell.textLabel.text = product.localizedTitle;
                    cell.detailTextLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ for %@", @"String containing the description of an in-app purchase followed by the cost."),
                                                 product.localizedDescription,
                                                 [numberFormatter stringFromNumber:product.price]];
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = NSLocalizedString(@"Restore Purchases", @"Label for link to restore purchases");
                }
			}
			break;
		case 2: // Support
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
	if (section == 1 &&
		([self.appDelegate.appStore hasTransactionsForAllProducts] || !self.appDelegate.appStore.canMakePayments)) {
		section++;
	}
	switch (section) {
		case 0:
			return NSLocalizedString(@"Events", @"Heading for list of events");
			break;
		case 1:
			return NSLocalizedString(@"Available Upgrades", @"Heading for list of available in-app purchases");
			break;
		case 2:
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
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	if (section == 1 &&
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section++;
	}
	switch (section) {
		case 0:
			break;
		case 1:
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
		case 2:
            return [NSString localizedStringWithFormat:NSLocalizedString(@"%@ version %@ (%@)", @"About view version footer"),
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
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
	if (indexPath.section >= 1 &&
		[self.appDelegate.appStore hasTransactionsForAllProducts]) {
		section = indexPath.section + 1;
	}
	self.showErrorAlert = YES;
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	switch (section) {
		case 0: // Activity
			if (indexPath.row != [[[NSUserDefaults standardUserDefaults] arrayForKey:eventsKey] count]) {
				// open eventSettingsViewController
//				EventSettingsViewController *controller = [[EventSettingsViewController alloc] initWithEventIndex:indexPath.row];
//				[self.navigationController pushViewController:controller animated:YES];
//				eventBeingUpdated = controller.index;
                [self editEvent:indexPath.row];
			} else if ([self.appDelegate.appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
				// add empty event to array
				[self addEvent];
			}
			break;
		case 1: // Store
			if (self.appDelegate.appStore.canMakePayments) {
                if (indexPath.row < self.appDelegate.appStore.products.count) {
                    SKProduct *product = [self.appDelegate.appStore.products objectForKey:[[self.appDelegate.appStore.products allKeys] objectAtIndex:indexPath.row]];
                    self.activityLabel.text = [NSString localizedStringWithFormat:NSLocalizedString(@"Getting %@...", @"Label indicating that app is getting an in-app purchase (with %@ as the title)"), product.localizedTitle];
                    [self hidePurchaseActivity:NO];
                    [self.appDelegate.appStore queuePaymentForProduct:product];
                } else {
                    self.activityLabel.text = NSLocalizedString(@"Restoring purchases...", @"Label indicating that app is restoring purchases");
                    [self hidePurchaseActivity:NO];
                    [self.appDelegate.appStore restoreCompletedTransactions];
                }
			}
			break;
		case 2: // About
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
                            [self presentViewController:mailController animated:YES completion:nil];
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
												 - self.activityView.frame.size.height);
		} else {
			self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
											  self.tableView.frame.origin.y,
											  self.tableView.frame.size.width,
											  self.tableView.frame.size.height + self.activityView.frame.size.height);
			self.activityView.frame = CGRectOffset(self.activityView.frame, 
												 0,
												 + self.activityView.frame.size.height);
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
	[self dismissViewControllerAnimated:YES completion:nil];
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
	self.activityLabel = nil;
	self.activityView = nil;
}

@end
