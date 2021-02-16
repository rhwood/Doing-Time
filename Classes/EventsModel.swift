//
//  EventsModel.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-12-09.
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

class EventsModel: ObservableObject {

    static let shared = EventsModel()

    static var preview: EventsModel = {
        let result = EventsModel(inMemory: true)
        for idx in 1...5 {
            result.events.append(Event(title: "Event \(idx)"))
        }
        return result
    }()

    @Published var events: [Event] = []

    init(inMemory: Bool = false) {
        if !inMemory {
            if let raw = UserDefaults.standard.array(forKey: "events") {
                for rawEvent in raw {
                    if let dict = rawEvent as? [String: Any] {
                        events.append(Event(title: dict["title"] as? String ?? "UNKNOWN",
                                            start: dict["start"] as? Date ?? Date(),
                                            end: dict["end"] as? Date ?? Date(),
                                            todayIs: Event.TodayIs(rawValue: dict["todayIs"] as? Int32
                                                                    ?? Event.TodayIs.remaining.rawValue)
                                                ?? Event.TodayIs.remaining,
                                            includeEnd: dict["includeLastDayInCalc"] as? Bool ?? true,
                                            showDates: dict["showEventDates"] as? Bool ?? true,
                                            showPercentages: dict["showPercentages"] as? Bool ?? true,
                                            showTotals: dict["showTotals"] as? Bool ?? true,
                                            showRemainingDaysOnly: dict["showCompletedDays"] as? Bool ?? true,
                                            completedColor:
                                                EventsModel.colorFromData(dict["completedColor"] as? Data),
                                            remainingColor:
                                                EventsModel.colorFromData(dict["remainingColor"] as? Data),
                                            backgroundColor:
                                                EventsModel.colorFromData(dict["backgroundColor"] as? Data)))
                    }
                }
            }
        }
    }

    private static func colorFromData(_ data: Data?) -> Color {
        guard let color = data else {
            return .black
        }
        do {
            return Color(try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: color) ?? .black)
        } catch {
            return .black
        }
    }

    private static func dataFromColor(_ color: Color) -> Data {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: true)
        } catch {
            return dataFromColor(.black)
        }
    }
}
