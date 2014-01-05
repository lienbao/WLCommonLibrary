//
//  UISearchBar+removeBackgroundView.m
//  AnjukeHD
//
//  Created by casa on 13-10-22.
//  Copyright (c) 2013年 anjuke. All rights reserved.
//

#import "UISearchBar+removeBackgroundView.h"

@implementation UISearchBar (removeBackgroundView)


- (void)removeBackgroundViewWithSubViews:(NSArray *)subviewArray
{
    for (UIView *subview in subviewArray) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            return;
        }
        if (subview.subviews.count > 0) {
            [self removeBackgroundViewWithSubViews:subview.subviews];
        }
    }
}

@end
