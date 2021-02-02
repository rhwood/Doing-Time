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
import CoreData

class PersistenceController {

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let newItem = Event()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    var events: [Event] = []
    var savable = false

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Event")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
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
                                                PersistenceController.colorFromData(dict["completedColor"] as? Data),
                                            remainingColor:
                                                PersistenceController.colorFromData(dict["remainingColor"] as? Data),
                                            backgroundColor:
                                                PersistenceController.colorFromData(dict["backgroundColor"] as? Data)))
                    }
                }
            }
            if events.count == 0 {
                events.append(Event())
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
