//
//  EventPageView.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-12-06.
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

struct EventPageView: View {
    var event: Event

    var body: some View {
        VStack {
            Text(event.title)
                .font(.largeTitle)
            showDates
            pieChart
            showComplete
            showTotals
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: EventSettingsView(event: event),
                    label: {
                        Text("Edit")
                    }).help("Edit event.")
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                }, label: {
                    Text("Delete Event")
                }).help("Delete event.")
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
        }
    }
}

extension EventPageView: EventViewElements {

}

struct EventPageView_Previews: PreviewProvider {
    static var uncounted = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .uncounted,
        includeEnd: true)
    static var complete = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .complete,
        includeEnd: true,
        showRemainingDaysOnly: true)
    static var remaining = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .remaining,
        includeEnd: true,
        showRemainingDaysOnly: false)
    static var previews: some View {
        NavigationView {
            EventPageView(event: uncounted)
        }
        NavigationView {
            EventPageView(event: complete)
        }
        NavigationView {
            EventPageView(event: remaining)
        }
    }
}
