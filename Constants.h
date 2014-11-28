/*
 *  Constants.h
 *  Doing Time
 *
 *  Created by Randall Wood on 5/3/2011.
 */
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

typedef NS_ENUM(NSInteger, TodayIs) {
    todayIsOver,
    todayIsNotCounted,
    todayIsRemaining
};

#pragma mark - App Store product identifiers

extern NSString *const multipleEventsProductIdentifier;

#pragma mark - Notifications

extern NSString *const eventMovedNotification;
extern NSString *const eventRemovedNotification;
extern NSString *const eventSavedNotification;
extern NSString *const selectedEventChanged;
