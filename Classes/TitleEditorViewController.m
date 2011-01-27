//
//  TitleEditorViewController.m
//
//  Created by Randall Wood on 2/1/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "TitleEditorViewController.h"

@implementation TitleEditorViewController

@synthesize delegate;
@synthesize titleView = _titleView;
@synthesize tableView = _tableView;
@synthesize titleViewCell = _titleViewCell;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.titleView.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Title"];
	self.titleView.borderStyle = UITextBorderStyleNone;
}

- (IBAction)done:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:self.titleView.text forKey:@"Title"];
    [self.delegate titleEditorViewControllerDidFinish:self];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.titleViewCell;
}

#pragma mark -
#pragma mark Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self done:nil];
}

@end
