//
//  RTColor.m
//  HaoZu
//
//  Created by omiyang on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (RTColor)

+ (UIColor *) colorWithHex:(uint) hex alpha:(CGFloat)alpha
{
	int red, green, blue;
	
	blue = hex & 0x0000FF;
	green = ((hex & 0x00FF00) >> 8);
	red = ((hex & 0xFF0000) >> 16);
	
	return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
