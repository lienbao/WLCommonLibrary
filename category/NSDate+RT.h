//
//  NSDate+RT.h
//  AiFang
//
//  Created by lh liu on 12-3-22.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RT)
+ (id)sharedInstance;
- (NSDateFormatter *)dateFormat;
- (NSString *)dateToString:(NSString *)format;
- (NSDate *)stringToDate:(NSString *)string format:(NSString *)format;
- (NSString *)stringToString:(NSString *)string format:(NSString *)format;
- (NSString *)getCurrentDateTime:(NSString *)format;
- (NSTimeInterval)intervalSinceFrom:(NSString *)fromDate to:(NSString *)toDate;
- (NSString *)changeTitle:(NSTimeInterval)time;
@end
