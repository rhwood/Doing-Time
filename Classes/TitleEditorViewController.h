//
//  TitleEditorViewController.h
//
//  Created by Randall Wood on 2/1/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TitleEditorViewControllerDelegate;


@interface TitleEditorViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    id <TitleEditorViewControllerDelegate> delegate;
	UITextField *_titleView;
	UITableView *_tableView;
	UITableViewCell *_titleViewCell;
}

- (IBAction)done:(id)sender;

@property (nonatomic, assign) id <TitleEditorViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet UITextField* titleView;
@property (nonatomic, assign) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* titleViewCell;

@end


@protocol TitleEditorViewControllerDelegate

- (void)titleEditorViewControllerDidFinish:(TitleEditorViewController *)controller;

@end
