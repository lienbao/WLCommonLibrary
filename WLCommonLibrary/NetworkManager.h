//
//  NetworkManager.h
//  Makecalls
//
//  Created by Lienbao on 13-10-23.
//  Copyright (c) 2013年 li enbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseNetworkService.h"

static NSString * const kWei64ServiceUrl = @"https://api.wei64.com/";

@interface NetworkManager : BaseNetworkService

+ (NetworkManager *)shareInstance;

+ (BOOL)checkoutResponse:(id)response andError:(NSError *)error;
+ (NSString *)errorDescription:(id)response default:(NSString *)error;

@end
