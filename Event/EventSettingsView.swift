//
//  EventSettings.swift
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

import SwiftUI

struct EventSettingsView: View {

    @StateObject var event: Event

    var body: some View {
        List {
            basicSettings
            dateSettings
            displaySettings
        }.listStyle(GroupedListStyle())
    }

    private var basicSettings: some View {
        Section {
            TextField("Title", text: $event.title)
            DatePicker("Start Date",
                       selection: $event.start,
                       displayedComponents: .date)
            DatePicker("End Date",
                       selection: $event.end,
                       in: event.start...,
                       displayedComponents: .date)
            HStack {
                Text("Duration")
                TextField("",
                          text: $event.totalDurationAsString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var dateSettings: some View {
        Section(header: Text("Dates")) {
            Toggle("Through End Date", isOn: $event.includeEnd)
            Picker(selection: $event.todayIs, label: Text("Treat Today As"), content: {
                Text("Completed").tag(Event.TodayIs.complete)
                Text("Uncounted").tag(Event.TodayIs.uncounted)
                Text("Remaining").tag(Event.TodayIs.remaining)
            })
        }
    }

    private var displaySettings: some View {
        Section(header: Text("Display")) {
            Toggle("Dates", isOn: $event.showDates)
            Toggle("Percentages", isOn: $event.showPercentages)
            Toggle("Totals", isOn: $event.showTotals)
            Toggle("Only Remaining Days", isOn: $event.showRemainingDaysOnly)
            ColorPicker("Completed Days", selection: $event.completedColor)
            ColorPicker("Remaining Days", selection: $event.remainingColor)
            ColorPicker("background", selection: $event.backgroundColor)
        }
    }
}

struct EventSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventSettingsView(event: Event())
        }
    }
}
