//
//  RTColor.m
//  HaoZu
//
//  Created by omiyang on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RTColor.h"

@implementation UIColor (RTColor)

//UIColor *blueColor = [UIColor colorWithHex:0x0174AC alpha:1];
+ (UIColor *) colorWithHex:(uint) hex alpha:(CGFloat)alpha
{
	int red, green, blue;
	
	blue = hex & 0x0000FF;
	green = ((hex & 0x00FF00) >> 8);
	red = ((hex & 0xFF0000) >> 16);
	
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
