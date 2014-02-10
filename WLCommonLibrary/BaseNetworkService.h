//
//  BaseNetworkService.h
//  WLCommonLibrary
//
//  Created by lienbao on 14-2-10.
//  Copyright (c) 2014年 wei64. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

static const double kTimeOutNetWork = 6.0f;

@interface BaseNetworkService : NSObject

@property (nonatomic, strong) NSString *baseURL;

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;

- (NSMutableDictionary *)commonWithParams:(NSDictionary *)params;

- (AFJSONRequestOperation *)asynWithMethod:(NSString *)method params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result;

@end
