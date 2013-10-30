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

@interface ColorPickerViewController : UIViewController <RSColorPickerViewDelegate> {
    
}

- (id)initWithColor:(UIColor *)color withTitle:(NSString *)title;
- (IBAction)resetColor:(id)sender;

@property IBOutlet RSColorPickerView* colorPicker;
@property IBOutlet RSBrightnessSlider* brightnessSlider;
@property IBOutlet ColorSelectionView* selectionView;
@property IBOutlet ColorSelectionView* startingView;

@property UIColor* selectedColor;

@end
