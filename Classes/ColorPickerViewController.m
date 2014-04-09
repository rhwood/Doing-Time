//
//  ColorPickerViewController.m
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//

#import "ColorPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString *const ColorDidChangeNotification = @"ColorDidChangeNotification";
NSString *const ColorKey = @"ColorKey";

@interface ColorPickerViewController ()

@end

@implementation ColorPickerViewController

@synthesize selectedColor = _selectedColor;

- (void)setSelectedColor:(UIColor *)color {
    _selectedColor = color;
    self.selectionView.selectedColor = color;
}

- (UIColor *)selectedColor {
    return _selectedColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.accessibilityLabel = self.navigationItem.title;
    
    self.colorPicker.cropToCircle = YES;
    self.colorPicker.selectionColor = self.selectedColor;
    self.brightnessSlider.value = self.colorPicker.brightness;
    self.selectionView.selectedColor = self.selectedColor;
    self.startingView.selectedColor = self.selectedColor;
    self.colorPicker.delegate = self;
    
    UIImage *clearImage = [[UIImage alloc] init];
    [self.brightnessSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
    [self.brightnessSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.brightnessSlider.bounds;
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[UIColor whiteColor].CGColor, nil];
    [self.brightnessSlider.layer insertSublayer:gradient atIndex:0];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.colorPicker.selectionColor = self.selectedColor;
    self.brightnessSlider.value = self.colorPicker.brightness;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:ColorDidChangeNotification object:self userInfo:@{ColorKey: self.colorKey}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetColor:(id)sender {
    self.colorPicker.selectionColor = self.startingView.selectedColor;
    self.brightnessSlider.value = self.colorPicker.brightness;
}

- (void)brightnessChanged:(id)sender {
    self.colorPicker.brightness = self.brightnessSlider.value;
}

#pragma - RSColorPickerView delegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    self.selectedColor = cp.selectionColor;
}

@end
