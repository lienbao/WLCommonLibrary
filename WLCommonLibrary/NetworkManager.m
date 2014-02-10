//
//  NetworkManager.m
//  Makecalls
//
//  Created by Lienbao on 13-10-23.
//  Copyright (c) 2013年 li enbao. All rights reserved.
//

#import "NetworkManager.h"
#import "UIDevice+IdentifierAddition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NetworkManager

+ (NetworkManager *)shareInstance
{
    static NetworkManager *_networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkManager = [[NetworkManager alloc] init];
        _networkManager.baseURL = kWei64ServiceUrl;
    });
    return _networkManager;
}


+ (BOOL)checkoutResponse:(id)response andError:(NSError *)error
{
    if (error) {
        DLog(@"error:%@", [error localizedDescription]);
        return FALSE;
    }
    if ([response isKindOfClass:[NSNull class]]) {
        return FALSE;
    }
    NSNumber *code = [response objectForKey:@"code"];
    if (200 != [code intValue]) {
        DLog(@"response:%@", response);
        return FALSE;
    }
    return TRUE;
}

+ (NSString *)errorDescription:(id)response default:(NSString *)error
{
    if ([response[@"detail"] length]) {
        return response[@"detail"];
    }
    return error;
}

- (NSMutableDictionary *)commonWithParams:(NSDictionary *)params
{
    NSMutableDictionary *paramsDic = nil;
    if (params) {
        paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
        paramsDic = [NSMutableDictionary dictionary];
    }
    [paramsDic setObject:[UIDevice identifier]    forKey:@"mac"];
    [paramsDic setObject:[UIDevice appName]       forKey:@"app"];
    [paramsDic setObject:[UIDevice appVersion]    forKey:@"version"];
    [paramsDic setObject:[UIDevice deviceType]    forKey:@"device"];
    [paramsDic setObject:[UIDevice ostype]        forKey:@"ostype"];
    [paramsDic setObject:[UIDevice getIPAddress]  forKey:@"Intranet_IP"];
    if ([[UIDevice oldUdid] length]) {
        [paramsDic setObject:[UIDevice oldUdid]  forKey:@"oldUdid"];
    }
    return paramsDic;
}

@end
