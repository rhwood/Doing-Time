//
//  TutorialViewController.m
//  Doing Time
//
//  Created by Randall Wood on 12/12/2013.
//
//

#import "TutorialViewController.h"
#import "Doing_TimeAppDelegate.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Tutorial" withExtension:@"html"];
    if ([((Doing_TimeAppDelegate *)[UIApplication sharedApplication].delegate).appStore hasTransactionForProduct:multipleEventsProductIdentifier]) {
        url = [[NSBundle mainBundle] URLForResource:@"MultipeEventsTutorial" withExtension:@"html"];
    }
    [self.view loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
