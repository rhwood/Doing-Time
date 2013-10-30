//
//  ColorPickerViewController.m
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController ()

@property NSString* navigationItemTitle;

@end

@implementation ColorPickerViewController

@synthesize selectedColor = _selectedColor;

- (id)initWithColor:(UIColor *)color withTitle:(NSString *)title {
    if ((self = [super initWithNibName:@"ColorPickerView" bundle:nil])) {
        self.selectedColor = color;
        self.navigationItemTitle = title;
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)color {
    _selectedColor = color;
    self.selectionView.selectedColor = color;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorSelectionDidChange" object:self userInfo:nil];
}

- (UIColor *)selectedColor {
    return _selectedColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = self.navigationItemTitle;
    self.accessibilityLabel = self.navigationItemTitle;
    
    self.colorPicker.cropToCircle = YES;
    self.colorPicker.selectionColor = self.selectedColor;
    self.brightnessSlider.colorPicker = self.colorPicker;
    self.brightnessSlider.value = self.colorPicker.brightness;
    self.selectionView.selectedColor = self.selectedColor;
    self.startingView.selectedColor = self.selectedColor;
    self.colorPicker.delegate = self;
    
    self.navigationController.navigationBar.translucent = NO;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    self.colorPicker.selectionColor = self.selectedColor;
//    self.brightnessSlider.value = self.colorPicker.brightness;
//}

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
