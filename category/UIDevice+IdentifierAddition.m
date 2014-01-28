//
//  UIDevice(Identifier).m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"
#import "UDIDWrapper.h"

#import  <ifaddrs.h>
#import  <arpa/inet.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <sys/utsname.h>
#include <net/if.h>
#include <net/if_dl.h>
#include "APService.h"

@interface UIDevice(Private)

- (NSString *) localMAC;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods

// Get IP Address
+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)identifier
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        return [[UIDevice currentDevice] macaddress];
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

+ (NSString *)deviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return machineType;
}

+ (NSString *)ostype
{
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];
}

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)localMAC
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
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods
- (NSString *) udid
{
    NSString *udid = [[UDIDWrapper sharedInstance] getOldUDID];
    if (udid.length > 0) {
        return udid;
    }
    
    udid = [[UDIDWrapper sharedInstance] getUDID];
    if (udid.length > 0) {
        return udid;
    }
    
    udid = [APService openUDID];
    if (udid) {
        [[UDIDWrapper sharedInstance] saveUDID:udid];
    }

    return udid;
}

- (NSString *)macaddress
{
    NSString *key = @"macAddress";
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (macAddress.length == 0) {
        macAddress = [self localMAC];
        if (macAddress.length>0){
            [[NSUserDefaults standardUserDefaults] setObject:macAddress forKey:key];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"macaddressMD5"];
        }
    }
    return macAddress;       
}

- (NSString *)macaddressMD5
{
    NSString *key = @"MACAddressMD5";
    NSString *macid = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (macid.length == 0) {
        NSString *macaddress = [[UIDevice currentDevice] macaddress];
        macid = [macaddress stringFromMD5];
        if (!macid){
            macid = @"macaddress_empty";
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:macid forKey:key];
        }
    }
    return macid;
}

@end
