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

class Event: ObservableObject, Identifiable, Codable {

    enum TodayIs: Int32 {
        case complete = 0
        case remaining = 1
        case uncounted = 2
    }

    @Published var title: String
    @Published var start: Date
    @Published var end: Date
    @Published var todayIs: TodayIs
    @Published var includeEnd: Bool
    @Published var showDates: Bool
    @Published var showPercentages: Bool
    @Published var showTotals: Bool
    @Published var showRemainingDaysOnly: Bool
    @Published var completedColor: Color
    @Published var remainingColor: Color
    @Published var backgroundColor: Color
    let id: UUID

    enum CodingKeys: String, CodingKey {
        case title
        case start
        case end
        case todayIs
        case includeEnd
        case showDates
        case showPercentages
        case showTotals
        case showRemainingDaysOnly
        case completedColor
        case remainingColor
        case backgroundColor
        case id
    }

    init(title: String = "",
         start: Date = Date(),
         end: Date = Date(),
         todayIs: TodayIs = .complete,
         includeEnd: Bool = true,
         showDates: Bool = true,
         showPercentages: Bool = true,
         showTotals: Bool = true,
         showRemainingDaysOnly: Bool = true,
         completedColor: Color = .green,
         remainingColor: Color = .red,
         backgroundColor: Color = .white,
         id: UUID = UUID()) {
        self.title = title
        self.start = start
        self.end = end
        self.todayIs = todayIs
        self.includeEnd = includeEnd
        self.showDates = showDates
        self.showPercentages = showPercentages
        self.showTotals = showTotals
        self.showRemainingDaysOnly = showRemainingDaysOnly
        self.completedColor = completedColor
        self.remainingColor = remainingColor
        self.backgroundColor = backgroundColor
        self.id = id
    }

    required init(from: Decoder) throws {
        let values = try from.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        start = try values.decode(Date.self, forKey: .start)
        end = try values.decode(Date.self, forKey: .end)
        todayIs = Event.TodayIs(rawValue: try values.decode(Int32.self, forKey: .todayIs)) ?? .complete
        includeEnd = try values.decode(Bool.self, forKey: .includeEnd)
        showDates = try values.decode(Bool.self, forKey: .showDates)
        showPercentages = try values.decode(Bool.self, forKey: .showPercentages)
        showTotals = try values.decode(Bool.self, forKey: .showTotals)
        showRemainingDaysOnly = try values.decode(Bool.self, forKey: .showRemainingDaysOnly)
        completedColor = EventsModel.colorFromData(try values.decode(Data.self, forKey: .completedColor))
        remainingColor = EventsModel.colorFromData(try values.decode(Data.self, forKey: .remainingColor))
        backgroundColor = EventsModel.colorFromData(try values.decode(Data.self, forKey: .backgroundColor))
        id = try values.decode(UUID.self, forKey: .id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(todayIs.rawValue, forKey: .todayIs)
        try container.encode(includeEnd, forKey: .includeEnd)
        try container.encode(showDates, forKey: .showDates)
        try container.encode(showPercentages, forKey: .showPercentages)
        try container.encode(showTotals, forKey: .showTotals)
        try container.encode(showRemainingDaysOnly, forKey: .showRemainingDaysOnly)
        try container.encode(EventsModel.dataFromColor(completedColor), forKey: .completedColor)
        try container.encode(EventsModel.dataFromColor(remainingColor), forKey: .remainingColor)
        try container.encode(EventsModel.dataFromColor(backgroundColor), forKey: .backgroundColor)
        try container.encode(id, forKey: .id)
    }

    var firstDay: Date {
        Calendar.current.startOfDay(for: start)
    }
    var lastDay: Date {
        let date = includeEnd ? Calendar.current.date(byAdding: .day, value: 1, to: end)! : end
        // return 1 second before end of day
        return Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.startOfDay(for: date))!
    }
    var totalDuration: Int {
        get {
            Calendar.current.dateComponents([.day], from: firstDay, to: lastDay).day! + 1
        }
        set {
            end = Calendar.current.date(byAdding: .day, value: includeEnd ? newValue - 1 : newValue, to: firstDay)!
        }
    }
    var totalDurationAsString: String {
        get {
            String(totalDuration)
        }
        set {
            totalDuration = NumberFormatter().number(from: newValue)?.intValue ?? totalDuration
        }
    }
    var completedDuration: Int {
        let today = Calendar.current.startOfDay(for: Date())
        if lastDay >= today && firstDay <= today {
            let duration = Calendar.current.dateComponents([.day], from: firstDay, to: today).day!
            switch todayIs {
            case .complete:
                return duration + 1
            default:
                return duration
            }
        } else if firstDay > today {
            return 0
        } else {
            return totalDuration
        }
    }
    var completedPercentage: Float {
        Float(completedDuration) / Float(totalDuration)
    }
    var remainingDuration: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        if firstDay <= tomorrow && lastDay >= today {
            let duration = Calendar.current.dateComponents([.day], from: lastDay, to: tomorrow).day! + 1
            switch todayIs {
            case .remaining:
                return duration < totalDuration ? duration + 1 : totalDuration
            case .complete:
                return duration + completedDuration <= totalDuration ? duration : 0
            default:
                return duration
            }
        } else if lastDay < today {
            return 0
        } else {
            return totalDuration
        }
    }
    var remainingPercentage: Float {
        Float(remainingDuration) / Float(totalDuration)
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
