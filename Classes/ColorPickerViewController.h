//
//  ColorPickerViewController.h
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

#import <UIKit/UIKit.h>
#import "RSColorPickerView.h"
#import "RSBrightnessSlider.h"
#import "ColorSelectionView.h"

extern NSString *const ColorDidChangeNotification;
extern NSString *const ColorKey;

@interface ColorPickerViewController : UIViewController <RSColorPickerViewDelegate> {
    
}

- (IBAction)resetColor:(id)sender;
- (IBAction)brightnessChanged:(id)sender;

@property IBOutlet RSColorPickerView* colorPicker;
@property IBOutlet UISlider* brightnessSlider;
@property IBOutlet ColorSelectionView* selectionView;
@property IBOutlet ColorSelectionView* startingView;

@property UIColor* selectedColor;
@property NSString* colorKey;

@end
