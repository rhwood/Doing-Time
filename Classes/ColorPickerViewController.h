//
//  ColorPickerViewController.h
//  Doing Time
//
//  Created by Randall Wood on 26/10/2013.
//
//

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
