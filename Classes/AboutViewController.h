//
//  AboutViewController.h
//  Doing Time
//
//  Created by Randall Wood on 18/4/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UITableViewController {

	UITableViewCell* _logoCell;

}

@property (nonatomic, retain) IBOutlet UITableViewCell* logoCell;
@end
