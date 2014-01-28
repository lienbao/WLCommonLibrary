//
//  KeychainWrapper.m
//  RTApiProxy
//
//  Created by liu lh on 13-6-24.
//
//

#import "UDIDWrapper.h"

static NSString *serviceName = @"com.wei64Apps";
static NSString *udidName = @"wei64AppsUDID";
static NSString *pasteboardType = @"wei64AppsContent";

static NSString *oldServiceName = @"com.anjukeApps";
static NSString *oldUdidName = @"anjukeAppsUDID";
static NSString *oldPasteboardType = @"anjukeAppsContent";

@implementation UDIDWrapper

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static UDIDWrapper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[UDIDWrapper alloc] init];
    });
    return sharedInstance;
}

- (NSString *)getOldUDID
{
    NSData *udidData = [self searchKeychainCopyMatching:oldUdidName andService:oldServiceName];
    NSString *udid = nil;
    if (udidData != nil) {
        NSString *temp = [[NSString alloc] initWithData:udidData encoding:NSUTF8StringEncoding];
        udid = [NSString stringWithFormat:@"%@", temp];
        [temp release];
    }
    return udid;

}

- (NSString *)getUDID{
    NSData *udidData = [self searchKeychainCopyMatching:udidName andService:serviceName];
    NSString *udid = nil;
    if (udidData != nil) {
        NSString *temp = [[NSString alloc] initWithData:udidData encoding:NSUTF8StringEncoding];
        udid = [NSString stringWithFormat:@"%@", temp];
        [temp release];
    }
    return udid;
}

- (void)saveUDID:(NSString *)udid{
    BOOL saveOk = NO;
    NSData *udidData = [self searchKeychainCopyMatching:udidName andService:serviceName];
    if (udidData == nil) {
        saveOk = [self createKeychainValue:udid forIdentifier:udidName andService:serviceName];
    }else{
        saveOk = [self updateKeychainValue:udid forIdentifier:udidName andService:serviceName];
    }
}

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier andSerivceName:(NSString *)service {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:service forKey:(id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier andService:(NSString *)service {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier andSerivceName:service];
    
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    NSData *result = nil;
    SecItemCopyMatching((CFDictionaryRef)searchDictionary,
                                          (CFTypeRef *)&result);
    
    [searchDictionary release];
    return result;
}

- (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier andService:(NSString *)service {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier andSerivceName:service];
    
    NSData *passwordData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
    [dictionary release];
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier andService:(NSString *)service {
    
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier andSerivceName:service];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *passwordData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:passwordData forKey:(id)kSecValueData];
    
    OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,
                                    (CFDictionaryRef)updateDictionary);
    
    [searchDictionary release];
    [updateDictionary release];
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier andService:(NSString *)service {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier andSerivceName:service];
    SecItemDelete((CFDictionaryRef)searchDictionary);
    [searchDictionary release];
}
@end
