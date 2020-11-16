/*
 *  Constants.h
 *  Doing Time
 *
 *  Created by Randall Wood on 5/3/2011.
 */
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
