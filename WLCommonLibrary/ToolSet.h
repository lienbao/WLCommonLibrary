//
//  UitiTool.h
//  Makecalls
//
//  Created by Lienbao on 13-10-23.
//  Copyright (c) 2013年 li enbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolSet : NSObject

+ (NSString *)macAddress;

+ (NSString *)appName;

+ (NSString *)appVersion;

+ (NSString *)identifier;

+ (CGFloat)lineWidth;

+ (CGFloat)contentViewHeight;

+ (CGFloat)navgationBarHeight;

+ (NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName;

@end
