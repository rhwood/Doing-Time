//
//  PersistenceController.swift
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

class PersistenceController {
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        // prepare preview
        result.events.append(Event())
        result.events.append(Event())
        result.events.append(Event())
        return result
    }()
    
    var events: [Event] = []
    var savable = false
    
    init(inMemory: Bool = false) {
        if !inMemory {
            if let raw = UserDefaults.standard.array(forKey: "events") {
                for rawEvent in raw {
                    if let dict = rawEvent as? [String: Any] {
                        events.append(Event(title: dict["title"] as? String ?? "UNKNOWN",
                                            start: dict["start"] as? Date ?? Date(),
                                            end: dict["end"] as? Date ?? Date(),
                                            todayIs: todayIsFromInt(dict["todayIs"] as? Int ?? 1),
                                            includeEnd: dict["includeLastDayInCalc"] as? Bool ?? true,
                                            showDates: dict["showEventDates"] as? Bool ?? true,
                                            showPercentages: dict["showPercentages"] as? Bool ?? true,
                                            showTotals: dict["showTotals"] as? Bool ?? true,
                                            showRemainingDaysOnly: dict["showCompletedDays"] as? Bool ?? true,
                                            completedColor: colorFromData(dict["completedColor"] as? Data),
                                            remainingColor: colorFromData(dict["remainingColor"] as? Data),
                                            backgroundColor: colorFromData(dict["backgroundColor"] as? Data)))
                    }
                }
            }
            if events.count == 0 {
                events.append(Event())
            }
        }
        savable = true
    }
    
    public func save() {
        if !savable {
            return
        }
        UserDefaults.standard.set(4, forKey: "version")
        var array: [[String: Any]] = []
        for event in events {
            array.append(["title": event.title,
                          "start": event.start,
                          "end": event.end,
                          "todayIs": intFromTodayIs(event.todayIs),
                          "includeLastDayInCalc": event.includeEnd,
                          "showEventDates": event.showDates,
                          "showPercentages": event.showPercentages,
                          "showTotals": event.showTotals,
                          "showCompletedDays": event.showRemainingDaysOnly,
                          "completedColor": dataFromColor(event.completedColor),
                          "remainingColor": dataFromColor(event.remainingColor),
                          "backgroundColor": dataFromColor(event.backgroundColor)])
        }
        UserDefaults.standard.set(array, forKey: "events")
    }
    
    public func insert(_ event: Event, at index: Int) {
        if index < events.count {
            events.insert(event, at: index)
        } else {
            events.append(event)
        }
        save()
    }
    
    public func remove(at index: Int) {
        events.remove(at: index)
        save()
    }
    
    private func todayIsFromInt(_ int: Int) -> Event.TodayIs {
        switch int {
        case 0:
            return .complete
        case 1:
            return .uncounted
        default:
            return .remaining
        }
    }
    
    private func intFromTodayIs(_ todayIs: Event.TodayIs) -> Int {
        switch todayIs {
        case .complete:
            return 0
        case .uncounted:
            return 1
        default:
            return 2
        }
    }
    
    private func colorFromData(_ data: Data?) -> Color {
        guard let color = data else {
            return .black
        }
        do {
            return Color(try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: color) ?? .black)
        } catch {
            return .black
        }
    }
    
    private func dataFromColor(_ color: Color) -> Data {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: true)
        } catch {
            return dataFromColor(.black)
        }
    }
}
