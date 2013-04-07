//
//  NSDateAdditions.m
//  Doing Time
//
//  Created by Randall Wood on 7/1/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "NSDate+Additions.h"


@implementation NSDate (AXAdditions)

+ (NSDate *)midnightForDate:(NSDate *)date {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *components = [calendar components:unitFlags fromDate:date];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [calendar dateFromComponents:components];
}

+ (NSDate *)UTCMidnightForDate:(NSDate *)date {
	NSTimeInterval interval = [[NSTimeZone localTimeZone] secondsFromGMTForDate:[NSDate midnightForDate:date]];
	return [NSDate dateWithTimeInterval:interval sinceDate:[NSDate midnightForDate:date]];
}

@end
