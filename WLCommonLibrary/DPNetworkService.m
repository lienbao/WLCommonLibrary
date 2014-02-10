//
//  DPNetworkService.m
//  WLCommonLibrary
//
//  Created by lienbao on 14-2-10.
//  Copyright (c) 2014年 wei64. All rights reserved.
//

#import "DPNetworkService.h"
#import <CommonCrypto/CommonDigest.h>

@interface DPNetworkService()

@end

@implementation DPNetworkService

+ (DPNetworkService *)shareInstance
{
    static DPNetworkService *_networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkManager = [[DPNetworkService alloc] init];
        _networkManager.baseURL = kDianpingServiceUrl;
    });
    return _networkManager;
}

- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{
 	NSMutableString *signString = [NSMutableString stringWithString:self.appKey];
	NSMutableString *paramsString = [NSMutableString stringWithFormat:@"appkey=%@", signString];
	NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(compare:)];
	for (NSString *key in sortedKeys) {
		[signString appendFormat:@"%@%@", key, [params objectForKey:key]];
		[paramsString appendFormat:@"&%@=%@", key, [params objectForKey:key]];
	}
	[signString appendString:self.appSecret];
    
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
