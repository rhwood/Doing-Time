/*
 *  Constants.h
 *  Doing Time
 *
 *  Created by Randall Wood on 5/3/2011.
 *  Copyright 2011 Alexandria Software. All rights reserved.
 *
 */


#pragma mark - UserDefaults dictionary keys

extern NSString *const titleKey;
extern NSString *const startKey;
extern NSString *const endKey;
extern NSString *const linkKey;
extern NSString *const eventsKey;
extern NSString *const multiEventTransactionKey;
extern NSString *const currentEventKey;
extern NSString *const showPercentageKey;
extern NSString *const showCompletedDaysKey;
extern NSString *const includeLastDayInCalcKey;
extern NSString *const showEventDatesKey;
extern NSString *const todayIsKey;
extern NSString *const transactionsKey;
extern NSString *const showTotalsKey;
extern NSString *const versionKey;
extern NSString *const completedColorKey;
extern NSString *const remainingColorKey;
extern NSString *const backgroundColorKey;

#pragma mark - Obsolete UserDefaults dictionary keys

extern NSString *const dayOverKey;

#pragma mark - Today constants

typedef enum {
    todayIsOver,
    todayIsNotCounted,
    todayIsRemaining
} TodayIs;

#pragma mark - App Store product identifiers

extern NSString *const multipleEventsProductIdentifier;