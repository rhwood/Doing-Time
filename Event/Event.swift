//
//  Event.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-21.
//
//  Copyright 2020 Randall Wood DBA Alexandria Software
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

import Foundation
import SwiftUI

struct Event {
    
    enum TodayIs {
        case complete
        case remaining
        case uncounted
    }
    
    var title = ""
    var start = Date()
    var firstDay: Date {
        return Calendar.current.startOfDay(for: start)
    }
    var end = Date()
    var lastDay: Date {
        var date = end
        if !includeEnd {
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
        // return 1 second before end of day
        return Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: date)!))!
    }
    var todayIs = TodayIs.complete
    var includeEnd = true
    var showDates = true
    var showPercentages = true
    var showTotals = true
    var showRemainingDaysOnly = true
    var completedColor = Color.green
    var remainingColor = Color.red
    var backgroundColor = Color.white
    var totalDuration: Int {
        set {
            end = Calendar.current.date(byAdding: .day, value: includeEnd ? newValue - 1 : newValue, to: firstDay)!
        }
        get {
            return Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day! + 1
        }
    }
    var totalDurationAsString: String {
        set {
            totalDuration = NumberFormatter().number(from: newValue) as! Int
        }
        get {
            return String(totalDuration)
        }
    }
    var completedDuration: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let duration = Calendar.current.dateComponents([.day], from: firstDay, to: today).day!
        switch todayIs {
        case .complete:
            return duration + 1
        default:
            return duration
        }
    }
    var completedPercentage: Float {
        return Float(completedDuration) / Float(totalDuration)
    }
    var remainingDuration: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let duration = Calendar.current.dateComponents([.day], from: lastDay, to: tomorrow).day! + 1
        switch todayIs {
        case .remaining:
            return duration < totalDuration ? duration + 1 : totalDuration
        case .complete:
            return duration + completedDuration <= totalDuration ? duration : 0
        default:
            return duration
        }
    }
    var remainingPercentage: Float {
        return Float(remainingDuration) / Float(totalDuration)
    }
    var todayPercentage: Float {
        switch todayIs {
        case .uncounted:
            return Float(1) / Float(totalDuration)
        default:
            return 0
        }
    }
    
}
