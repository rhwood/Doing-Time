//
//  ColorPickerViewController.m
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//  Copyright 2013-2014, 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    CGFloat edge = ((self.view.bounds.size.width < self.view.bounds.size.height) ? self.view.bounds.size.width : self.view.bounds.size.height)
    - (2 * (self.view.layoutMargins.left + self.view.layoutMargins.right));
    [self.colorPicker setFrame:CGRectMake(self.view.layoutMargins.left, self.colorPicker.frame.origin.y, edge, edge)];
    [self.brightnessSlider setFrame:CGRectMake(self.view.layoutMargins.left, self.brightnessSlider.frame.origin.y, edge, self.brightnessSlider.frame.size.height)];
    for (CALayer* sublayer in self.brightnessSlider.layer.sublayers) {
        sublayer.frame = self.brightnessSlider.bounds;
    }
    [self.brightnessSlider.layer layoutSublayers];
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
