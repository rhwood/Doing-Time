//
//  ColorSelectionView.m
//  Doing Time
//
//  Created by Randall Wood on 28/10/2013.
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
