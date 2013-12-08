/*
 *  Constants.h
 *  Doing Time
 *
 *  Created by Randall Wood on 5/3/2011.
 *  Copyright 2011 Alexandria Software. All rights reserved.
 *
 */

#pragma mark - UserDefaults dictionary keys

NSString *const titleKey = @"title";
NSString *const startKey = @"start";
NSString *const endKey = @"end";
NSString *const linkKey = @"identifier";
NSString *const eventsKey = @"events";
NSString *const multiEventTransactionKey = @"multipleEvents";
NSString *const currentEventKey = @"currentEvent";
NSString *const showPercentageKey = @"showPercentages";
NSString *const showCompletedDaysKey = @"showCompletedDays";
NSString *const includeLastDayInCalcKey = @"includeLastDayInCalc";
NSString *const showEventDatesKey = @"showEventDates";
NSString *const todayIsKey = @"todayIs";
NSString *const transactionsKey = @"AppStoreTransactions";
NSString *const showTotalsKey = @"showTotals";
NSString *const versionKey = @"version";
NSString *const completedColorKey = @"completedColor";
NSString *const remainingColorKey = @"remainingColor";
NSString *const backgroundColorKey = @"backgroundColor";

#pragma mark - Obsolete UserDefaults dictionary keys

NSString *const dayOverKey = @"dayIsOverAt";

#pragma mark - App Store product identifiers

NSString *const multipleEventsProductIdentifier = @"com.alexandriasoftware.doingtime.multipleEvents";

#pragma mark - Norifications

NSString *const eventMovedNotification = @"eventMovedNotification";
NSString *const eventRemovedNotification = @"eventRemovedNotification";
NSString *const eventSavedNotification = @"eventSavedNotification";
NSString *const selectedEventChanged = @"selectedEventChanged";
