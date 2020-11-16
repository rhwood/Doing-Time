//
//  ColorSelectionView.m
//  Doing Time
//
//  Created by Randall Wood on 28/10/2013.
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

#import "ColorSelectionView.h"

@interface ColorSelectionView ()

@property (nonatomic) UIColor *outerRingColor;
@property (nonatomic) UIColor *innerRingColor;

@end

@implementation ColorSelectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.exclusiveTouch = YES;
        _outerRingColor = [UIColor colorWithWhite:0.7 alpha:1.0];
		_innerRingColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, self.selectedColor.CGColor);
	CGContextFillRect(ctx, CGRectInset(rect, 0, 0));
	CGContextSetLineWidth(ctx, 1);
	CGContextSetStrokeColorWithColor(ctx, _outerRingColor.CGColor);
	CGContextStrokeRect(ctx, CGRectInset(rect, 0, 0));
	CGContextSetLineWidth(ctx, 1);
	CGContextSetStrokeColorWithColor(ctx, _innerRingColor.CGColor);
	CGContextStrokeRect(ctx, CGRectInset(rect, 0, 0));
}

@end
