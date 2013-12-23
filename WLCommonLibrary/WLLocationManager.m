//
//  RTLocationManager.m
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "WLLocationManager.h"
#import <UIKit/UIKit.h>

@implementation WLLocationManager
@synthesize locationManager = _locationManager;
@synthesize userLocation = _userLocation;
@synthesize mapUserLocation = _mapUserLocation;

+ (WLLocationManager *)sharedInstance
{
    static dispatch_once_t pred;
    static WLLocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[WLLocationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 500;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locatedCity  = @"-1";
    }
    return self;
}

- (CLLocation *)userLocation {
    if (self.locationManager.location == nil)
        [self restartLocation];
    
    return self.locationManager.location;
}

- (void)setSelectedCity:(NSString *)selectedCity
{
    if ([self.selectedCity isEqualToString:selectedCity]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:selectedCity forKey:@"selectedCity"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WLCityChangeNotification object:nil];
    
}

- (NSString *)selectedCity
{
    NSString *city = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedCity"];
    if ([city length]) {
        return city;
    }
    return @"上海";
}

- (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (RTCLServiceStatus)locationServicesStatus{
    RTCLServiceStatus status = RTCLServiceStatusUnknowError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"4.2")) {
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            switch (authorizationStatus) {
                case kCLAuthorizationStatusNotDetermined:
                    status = RTCLServiceStatusFirst;
                    break;
                case kCLAuthorizationStatusAuthorized:
                    status = RTCLServiceStatusOK;
                    break;
                case kCLAuthorizationStatusDenied:
                    status = RTCLServiceStatusDenied;
                    break;
                default:
                        status = RTCLServiceStatusNoNetwork;
                    break;
            }
        }
    }else {
        status = RTCLServiceStatusDenied;
    }
    return status;
}

- (void)restartLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)startLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }    
}

- (void)stopLocation {
    if ([self locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    }        
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self fetchCityInfoWithLocation:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locatedCity = @"-1";
    [[NSNotificationCenter defaultCenter] postNotificationName:WLGetLocatedCityNotification object:error];
}

- (CLLocation *)mapUserLocation {
    if (!_mapUserLocation)
        _mapUserLocation = self.userLocation;
    
    return  _mapUserLocation;
}

#pragma mark - Update GPS city
- (void)fetchCityInfoWithLocation:(CLLocation *)location
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placeMarkArray, NSError *error){
        CLPlacemark *placemark = [placeMarkArray lastObject];
        if (placemark) {
            NSString *cityName = nil;
            NSDictionary *addressDictionary = placemark.addressDictionary;
            for (NSString *key in addressDictionary.allKeys) {
                if ([key isEqualToString:@"City"]) {
                    NSString *completeCityName = addressDictionary[@"City"];
                    //上海市 => 上海
                    cityName = [completeCityName substringToIndex:(completeCityName.length - 1)];
                    break;
                }
                
                if ([key isEqualToString:@"State"]) {
                    //上海市只在"State"中出现，有可能直辖市都只是在State中出现。
                    NSString *completeCityName = addressDictionary[@"State"];
                    //要检查一下这个state是不是包含“市”这个字，因为也有可能是江苏省。
                    NSRange range = [completeCityName rangeOfString:@"市"];
                    if (range.location != NSNotFound) {
                        cityName = [completeCityName substringToIndex:(completeCityName.length - 1)];
                        break;
                    }
                }
            }
            self.locatedCity = cityName;
            [[NSNotificationCenter defaultCenter] postNotificationName:WLGetLocatedCityNotification object:error];
        }
    }];
}
@end
