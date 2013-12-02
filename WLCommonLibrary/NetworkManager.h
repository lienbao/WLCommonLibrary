//
//  NetworkManager.h
//  Makecalls
//
//  Created by Lienbao on 13-10-23.
//  Copyright (c) 2013年 li enbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, NMServiceType) {
    NMServiceWei64,
    NMServiceDianping,
    NMServiceInvalid,
};

static const double kTimeOutNetWork = 6.0f;
static NSString * const kDianpingAppkey = @"03028502";
static NSString * const kDianpingSecret = @"8d25190423204c5f8dd242fccfcca6e9";

@interface NetworkManager : NSObject

+ (NetworkManager *)shareInstance;

+ (BOOL)checkoutResponse:(id)response andError:(NSError *)error;
+ (NSString *)errorDescription:(id)response default:(NSString *)error;

- (void)requestWithmethodName:(NSString *)methodName params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result;

- (AFJSONRequestOperation *)requestWithService:(NMServiceType )service methodName:(NSString *)methodName params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result;

@end
