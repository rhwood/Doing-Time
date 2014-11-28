/*
 *  Constants.h
 *  Doing Time
 *
 *  Created by Randall Wood on 5/3/2011.
 */
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
