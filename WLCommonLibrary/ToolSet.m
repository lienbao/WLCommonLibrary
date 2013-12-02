//
//  UitiTool.m
//  Makecalls
//
//  Created by Lienbao on 13-10-23.
//  Copyright (c) 2013年 li enbao. All rights reserved.
//

#import "ToolSet.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "UIDevice+IdentifierAddition.h"

@implementation ToolSet

+ (NSString *)identifier
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        return [self macAddress];
    }
    return [[UIDevice currentDevice] udid];
}

+ (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
}

+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)macAddress
{
    int                 mib[6];
	size_t              len;
	char                *buf;
	unsigned char       *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl  *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		NSLog(@"Error: if_nametoindex error/n");
		return nil;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		NSLog(@"Error: sysctl, take 1/n");
		return nil;
	}
	
	if ((buf = malloc(len)) == NULL) {
		NSLog(@"Could not allocate memory. error!/n");
		return nil;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		NSLog(@"Error: sysctl, take 2");
		return nil;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

+ (CGFloat)navgationBarHeight
{
    static CGFloat height = 0;
    if (0 == height) {
        if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            height = 64;
        } else {
            height = 44;
        }
    }
    return height;
}

+ (CGFloat)lineWidth
{
    static CGFloat width = 0;
    if (0 == width) {
        if ( 2 == [[UIScreen mainScreen] scale]) {
            width = 0.5;
        } else {
            width = 1;
        }
    }
    return width;
}

+ (CGFloat)contentViewHeight
{
    CGFloat height = CGRect_FULLSCREEN.size.height - 64 - 44 - 6;
    return height;
}

+ (NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName
{
    if (![paramName hasSuffix:@"="])
    {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    
    NSString * str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound)
    {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0)
        {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#')
        {
            NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = end.location == NSNotFound ?
            [url substringFromIndex:offset] :
            [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return str;
}

@end
