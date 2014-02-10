//
//  BaseNetworkService.m
//  WLCommonLibrary
//
//  Created by lienbao on 14-2-10.
//  Copyright (c) 2014年 wei64. All rights reserved.
//

#import "BaseNetworkService.h"
#import "UIDevice+IdentifierAddition.h"

@implementation BaseNetworkService

- (AFJSONRequestOperation *)asynWithMethod:(NSString *)method params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result
{
    NSURL *url = [self buildURLWithMethod:method params:params];
    if (!url) {
        result(nil, nil);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOutNetWork];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if (result) {
                                                                                                result(JSON, nil);
                                                                                            }
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                                                                            if (result) {
                                                                                                result(JSON, nil);
                                                                                            }
                                                                                        }];
    [operation start];
    return operation;
}

- (NSMutableDictionary *)commonWithParams:(NSDictionary *)params
{
    NSMutableDictionary *paramsDic = nil;
    if (params) {
        paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
        paramsDic = [NSMutableDictionary dictionary];
    }
    return paramsDic;
}

- (NSURL *)buildURLWithMethod:(NSString *)method params:(NSDictionary *)params
{
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@", self.baseURL, method];
    NSMutableDictionary *paramsDic = [self commonWithParams:params];
    NSString *requestStr = [self serializeURL:baseUrl params:paramsDic];
    DLog(@"url:%@", requestStr);
    if (!requestStr) {
        return nil;
    }
    return [NSURL URLWithString:requestStr];
}

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{
    NSMutableString *paramsString = [NSMutableString string];
    for (NSString *key in [params allKeys]) {
        NSString *value = [params objectForKey:key];
        if ([value isKindOfClass:[NSString class]] && [value length] ){
            value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)value,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
            if ([paramsString length]) {
                [paramsString appendFormat:@"&%@=%@", key, value];
            }else {
                [paramsString appendFormat:@"%@=%@", key, value];
            }
        }
    }
    return [NSString stringWithFormat:@"%@?%@", baseURL, paramsString];
}

@end
