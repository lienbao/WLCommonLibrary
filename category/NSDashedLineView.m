//
//  HZDashedLineView.m
//  AnjukeHD
//
//  Created by casa on 13-8-17.
//  Copyright (c) 2013年 anjuke. All rights reserved.
//

#import "NSDashedLineView.h"
#import "UIView+Frame.h"

@interface NSDashedLineView ()

@property (nonatomic, strong) UIColor *color;

@end

@implementation NSDashedLineView

-(id)initWithFrame:(CGRect)frame withColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.color = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, [self height]);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    float lengths[] = {4,4};
    CGContextSetLineDash(context, 0, lengths,1);
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, [self width],0.0f);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

@end
