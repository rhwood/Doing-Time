//
//  ColorSelectionView.m
//  Doing Time
//
//  Created by Randall Wood on 28/10/2013.
//
//

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
