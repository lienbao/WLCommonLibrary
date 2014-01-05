//
//  NSDate+RT.m
//  AiFang
//
//  Created by lh liu on 12-3-22.
//  Copyright (c) 2012年 anjuke. All rights reserved.
//

#import "NSDate+RT.h"

@implementation NSDate (RT)
+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static NSData *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSDateFormatter *)dateFormat{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:NSLocalizedString(@"yyyy-MM-dd HH:mm:ss",nil)];
    return formatter;
}

- (NSString *)dateToString:(NSString *)format {
	NSDateFormatter *formatter = [self dateFormat];
    if (![format isEqualToString:@""]&&format != nil) {
        [formatter setDateFormat:format];
    }
    return [formatter stringFromDate:self];
}

- (NSDate *)stringToDate:(NSString *)string format:(NSString *)format {
	NSDateFormatter *formatter = [self dateFormat];
    if (![format isEqualToString:@""]&&format != nil) {
        [formatter setDateFormat:format];
    }
    return [formatter dateFromString:string];
}

- (NSString *)stringToString:(NSString *)string format:(NSString *)format{
    NSDate *nsDate = [self stringToDate:string format:nil];
    NSString *str = [nsDate dateToString:format];
    return str;
}

- (NSString *)getCurrentDateTime:(NSString *)format{
    NSDate *date = [NSDate date];
    NSString *string = [date dateToString:format];
    return string;
}

- (NSTimeInterval)intervalSinceFrom:(NSString *)fromDate to:(NSString *)toDate{
    NSDate *date1,*date2;
    if ([fromDate isEqualToString:@""] || fromDate == nil) {
        date1 = [NSDate date];
    }else{
        date1 = [self stringToDate:fromDate format:NSLocalizedString(@"yyyy-MM-dd HH:mm:ss",nil)];
    }
    if ([toDate isEqualToString:@""] || toDate == nil) {
        date2 = [NSDate date];
    }else{
        date2 = [self stringToDate:toDate format:NSLocalizedString(@"yyyy-MM-dd HH:mm:ss",nil)];
    }
    NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
    return time;
//    if (time<=0) {
//        return @"已结束";
//    }
//    int days = ((int)time)/(60*60*24); 
//    time = ((int)time)%(60*60*24);
//    int hours = ((int)time)/(60*60);
//    time = ((int)time)%(60*60);
//    int mins = ((int)time)/(60);
//    NSString *dateContent = [NSString stringWithFormat:@"%d天%d小时%d分",days,hours,mins];
//    return dateContent;
}
- (NSString *)changeTitle:(NSTimeInterval)time{
    if (time<=0) {
        return @"已结束";
    }
    int days = ((int)time)/(60*60*24); 
//    time = ((int)time)%(60*60*24);
//    int hours = ((int)time)/(60*60);
//    time = ((int)time)%(60*60);
//    int mins = ((int)time)/(60);
//    NSString *dateContent = [NSString stringWithFormat:@"%d天%d小时%d分",days,hours,mins];
    NSString *dateContent = [NSString stringWithFormat:@"%d天",days];
    return dateContent;
}
@end
