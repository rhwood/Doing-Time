//
//  NSDateAdditions.m
//  Doing Time
//
//  Created by Randall Wood on 7/1/2011.
//
//  Copyright 2011-2014, 2020 Randall Wood DBA Alexandria Software
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NSDate+Additions.h"


@implementation NSDate (AXAdditions)

+ (NSDate *)midnightForDate:(NSDate *)date {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
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
