//
//  RTLocationManager.h
//  AiFang
//
//  Created by zheng yan on 12-4-24.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define WLGetLocatedCityNotification @"WLGetLocatedCityNotification"
#define WLCityChangeNotification     @"WLCityChangeNotification"

typedef enum {
    RTCLServiceStatusFirst,//定位第一次打开 ios4.2以上
    RTCLServiceStatusOK,//定位服务开启
    RTCLServiceStatusDenied, //用户拒绝服务
    RTCLServiceStatusNoNetwork,//用户网络未开
    RTCLServiceStatusUnknowError //其他错误
} RTCLServiceStatus;//定位服务状态

@interface WLLocationManager : NSObject <CLLocationManagerDelegate>

+ (WLLocationManager *)sharedInstance;
- (id)init;

@property (unsafe_unretained, nonatomic, readonly) CLLocation *userLocation;
@property (nonatomic, strong) CLLocation *mapUserLocation;    // use user location in MKMapView. 
@property (nonatomic, copy)   NSString *locatedCity;
@property (nonatomic, copy)   NSString *selectedCity;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;
- (BOOL)locationServicesEnabled;

//new
- (RTCLServiceStatus)locationServicesStatus;
- (void)fetchCityInfoWithLocation:(CLLocation *)location;
@end
