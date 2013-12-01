//
//  InfoViewController.h
//  Doing Time
//
//  Created by Randall Wood on 28/11/2013.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Doing_TimeAppDelegate;

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (strong) Doing_TimeAppDelegate *appDelegate;

@end
