//
//  EventView.swift
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

struct EventView: View {

    var event: Event

    @ViewBuilder
    var body: some View {
        VStack {
            Text(event.title)
                .font(.largeTitle)
            if event.showDates {
                showDates
            }
            pieChart
            if !event.showRemainingDaysOnly {
                if event.showTotals && event.showPercentages {
                    Text(event.completedDuration != 1
                            ? "\(event.completedDuration) days (\(percentComplete)%) complete"
                            : "\(event.completedDuration) day (\(percentComplete)%) complete")
                } else if event.showTotals {
                    Text(event.completedDuration != 1
                            ? "\(event.completedDuration) days complete"
                            : "\(event.completedDuration) day complete")
                } else if event.showPercentages {
                    Text("\(percentComplete)% complete")
                }
            }
            if event.showTotals && event.showPercentages {
                Text(event.remainingDuration != 1
                        ? "\(event.remainingDuration) days (\(percentRemaining)%) left"
                        : "\(event.remainingDuration) day (\(percentRemaining)%) left")
            } else if event.showTotals {
                Text(event.remainingDuration != 1
                        ? "\(event.remainingDuration) days left"
                        : "\(event.remainingDuration) day left")
            } else if event.showPercentages {
                Text("\(percentRemaining)% left")
            }
        }
    }
}

extension EventView: EventViewElements {

}

struct EventView_Previews: PreviewProvider {
    static var uncounted = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .uncounted,
        includeEnd: true)
    static var complete = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .complete,
        includeEnd: true)
    static var remaining = Event(title: "Preview",
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        end: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        todayIs: .remaining,
        includeEnd: true)
    static var previews: some View {
        EventView(event: uncounted)
        EventView(event: complete)
        EventView(event: remaining)
    }
}
