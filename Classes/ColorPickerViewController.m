//
//  ColorPickerViewController.m
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//

#import "ColorPickerViewController.h"

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
    self.brightnessSlider.colorPicker = self.colorPicker;
    self.brightnessSlider.value = self.colorPicker.brightness;
    self.selectionView.selectedColor = self.selectedColor;
    self.startingView.selectedColor = self.selectedColor;
    self.colorPicker.delegate = self;
    
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

#pragma - RSColorPickerView delegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
    self.selectedColor = cp.selectionColor;
}

@end
