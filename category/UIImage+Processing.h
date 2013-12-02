//
//  UIImage+Processing.h
//  Wallpaper
//
//  Created by  leb on 13-10-8.
//  Copyright (c) 2013年 anjuke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Processing)

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)imageWithSize:(CGSize)size;

@end
