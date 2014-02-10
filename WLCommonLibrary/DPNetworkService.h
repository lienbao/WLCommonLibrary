//
//  DPNetworkService.h
//  WLCommonLibrary
//
//  Created by lienbao on 14-2-10.
//  Copyright (c) 2014年 wei64. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseNetworkService.h"

static NSString * const kDianpingServiceUrl = @"http://api.dianping.com/v1";

@interface DPNetworkService : BaseNetworkService

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;

+ (DPNetworkService *)shareInstance;

@end
