//
//  ColorPickerViewController.m
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//  Copyright (c) 2013-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
