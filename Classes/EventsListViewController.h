//
//  EventsListViewController.h
//  Doing Time
//
//  Created by Randall Wood on 6/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"

@interface EventsListViewController : ATSDragToReorderTableViewController

@property (strong) NSCalendar *calendar;

@end
