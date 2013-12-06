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

static NSString * const kWei64ServiceUrl    = @"http://api.wei64.com:10001/1";
static NSString * const kDianpingServiceUrl = @"http://api.dianping.com/v1";

@implementation NetworkManager

+ (NetworkManager *)shareInstance
{
    static NetworkManager *_networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkManager = [[NetworkManager alloc] init];
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

- (AFJSONRequestOperation *)requestWithService:(NMServiceType )service methodName:(NSString *)methodName params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result
{
    NSURL *url = [self buildURLWithService:service methodName:methodName params:params];
    if (!url) {
        result(nil, nil);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeOutNetWork];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            result(JSON, nil);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
                                                                                            result(JSON, error);
                                                                                        }];
    [operation start];
    return operation;
}

- (void)requestWithmethodName:(NSString *)methodName params:(NSDictionary *)params result:(void (^)(id JSON, NSError *error))result
{
    [self requestWithService:NMServiceWei64 methodName:methodName params:params result:result];
}

#pragma mark - private method
- (NSString *)implodeWithDictionary:(NSDictionary *)dic withSeparator:(NSString *)str encode:(BOOL)encode
{
    //为了和andriod一直所以使用key=value后再排序
    NSMutableArray *keyValues = [NSMutableArray array];
    for (NSString *key in [dic allKeys]) {
        id value = [dic objectForKey:key];
        if (![[NSNull null] isEqual:value] && ![@"" isEqualToString:value]){
            if (encode) {
                value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)value,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
            }
            NSString *temp = [NSString stringWithFormat:@"%@%@=%@", str, key, value];
            [keyValues addObject:temp];
        }
    }
    
    NSArray *newKeyValues = [keyValues sortedArrayUsingSelector:@selector(compare:)];
    NSString *temp = @"";
    for (NSString *value in newKeyValues) {
        temp = [NSString stringWithFormat:@"%@%@", temp, value];
    }
    if (temp.length>1) {
        temp = [temp substringFromIndex:1];
    }else{
        temp = temp;
    }
    return temp;
}

- (NSURL *)buildURLWithService:(NMServiceType )service methodName:(NSString *)methodName params:(NSDictionary *)params
{
    if (![methodName length]) {
        return nil;
    }
    
    if (params && ![params isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *requestStr = nil;
    switch (service) {
        case NMServiceWei64:
        {
            NSMutableDictionary *paramsDic = nil;
            if (params) {
                paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
            } else {
                paramsDic = [NSMutableDictionary dictionary];
            }
            [paramsDic setObject:[UIDevice identifier]  forKey:@"mac"];
            [paramsDic setObject:[UIDevice appName]     forKey:@"app"];
            [paramsDic setObject:[UIDevice appVersion]  forKey:@"version"];
            [paramsDic setObject:[UIDevice deviceType]  forKey:@"device"];
            [paramsDic setObject:[UIDevice ostype]  forKey:@"ostype"];
            NSString *beforeEncode = [self implodeWithDictionary:paramsDic withSeparator:@"&" encode:NO];
            NSString *strParams = [NSString stringWithFormat:@"%@",[beforeEncode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            requestStr = [NSString stringWithFormat:@"%@/%@?%@", kWei64ServiceUrl, methodName, strParams];
        }
            break;
        case NMServiceDianping:
        {
            NSString *baseUrl = [NSString stringWithFormat:@"%@%@", kDianpingServiceUrl, methodName];
            requestStr = [[self class] serializeURL:baseUrl params:params];
        }
            break;
        default:
            break;
    }
    DLog(@" url:%@", requestStr);
    if (!requestStr) {
        return nil;
    }
    
    return [NSURL URLWithString:requestStr];
}

#pragma mark - Public Methods
+ (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
		
		if ([elements count] <= 1) {
			return nil;
		}
		
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{	
	NSMutableString *signString = [NSMutableString stringWithString:kDianpingAppkey];
	NSMutableString *paramsString = [NSMutableString stringWithFormat:@"appkey=%@", signString];
	NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(compare:)];
	for (NSString *key in sortedKeys) {
		[signString appendFormat:@"%@%@", key, [params objectForKey:key]];
		[paramsString appendFormat:@"&%@=%@", key, [params objectForKey:key]];
	}
	[signString appendString:kDianpingSecret];
    
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	NSData *stringBytes = [signString dataUsingEncoding: NSUTF8StringEncoding];
	if (CC_SHA1([stringBytes bytes], [stringBytes length], digest)) {
		/* SHA-1 hash has been calculated and stored in 'digest'. */
		NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
		for (int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
			unsigned char aChar = digest[i];
			[digestString appendFormat:@"%02X", aChar];
		}
		[paramsString appendFormat:@"&sign=%@", [digestString uppercaseString]];
		return [NSString stringWithFormat:@"%@?%@", baseURL, [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	} else {
		return nil;
	}
}

@end
