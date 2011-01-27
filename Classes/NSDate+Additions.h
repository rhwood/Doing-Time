//
//  NSDateAdditions.h
//  Doing Time
//
//  Created by Randall Wood on 7/1/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (AXAdditions)

+ (NSDate *)midnightForDate:(NSDate *)date;
+ (NSDate *)UTCMidnightForDate:(NSDate *)date;

@end
