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

    @Binding var event: Event

    var body: some View {
        List {
            Section {
                TextField("Title", text: self.$event.title)
                HStack {
                    DatePicker("Start Date",
                               selection: self.$event.start,
//                               in: ...self.$event.end,
                               displayedComponents: .date)
                }
                HStack {
                    DatePicker("End Date",
                               selection: self.$event.start,
//                               in: self.$event.start...
                               displayedComponents: .date)
                }
                HStack {
                    Text("Duration")
                    TextField("",
                              text: self.$event.totalDurationAsString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section(header: Text("Dates")) {
                Toggle("Through End Date", isOn: $event.includeEnd)
                Picker(selection: $event.todayIs, label: Text("Treat Today As"), content: {
                    Text("Completed").tag(Event.TodayIs.complete)
                    Text("Uncounted").tag(Event.TodayIs.uncounted)
                    Text("Remaining").tag(Event.TodayIs.remaining)
                })
            }
            Section(header: Text("Display")) {
                Toggle("Show Dates", isOn: $event.showDates)
                Toggle("Percentages", isOn: $event.showPercentages)
                Toggle("Totals", isOn: $event.showTotals)
                Toggle("Only Remaining Days", isOn: $event.showRemainingDaysOnly)
                ColorPicker("Completed Days", selection: $event.completedColor)
                ColorPicker("Remaining Days", selection: $event.remainingColor)
                ColorPicker("background", selection: $event.backgroundColor)
            }
        }.listStyle(GroupedListStyle())
    }
}

struct EventSettings_Previews: PreviewProvider {
    @State static var event = Event()
    static var previews: some View {
        EventSettingsView(event: $event)
    }
}
