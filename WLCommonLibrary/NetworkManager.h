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
static NSString * const kDianpingSecret = @"fb1026a1694d45aab79e9a0741e50560";

@interface NetworkManager : NSObject

+ (NetworkManager *)shareInstance;

+ (BOOL)checkoutResponse:(id)response andError:(NSError *)error;
+ (NSString *)errorDescription:(id)response default:(NSString *)error;

- (AFJSONRequestOperation *)asynWithMethod:(NSString *)method params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result;

- (AFJSONRequestOperation *)asynWithService:(NMServiceType )service method:(NSString *)method params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result;

@end
