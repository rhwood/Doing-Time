//
//  NSDateAdditions.m
//  Doing Time
//
//  Created by Randall Wood on 7/1/2011.
//
//  Copyright (c) 2011-2014 Randall Wood
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
