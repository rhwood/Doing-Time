//
//  EventCellView.swift
//  Doing Time
//
//  Created by Randall Wood on 2/7/21.
//

import SwiftUI

struct EventCellView: View {
    
    var event: Event

    var body: some View {
        HStack(alignment: .center) {
            pieChart
            .frame(width: 44, height: 44, alignment: .center)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                if event.showDates {
                    showDates
                        .font(.caption)
                }
                if !event.showRemainingDaysOnly {
                    if event.showTotals && event.showPercentages {
                        Text(event.completedDuration != 1
                                ? "\(event.completedDuration) days (\(percentComplete)%) complete"
                                : "\(event.completedDuration) day (\(percentComplete)%) complete")
                            .font(.caption)
                    } else if event.showTotals {
                        Text(event.completedDuration != 1
                                ? "\(event.completedDuration) days complete"
                                : "\(event.completedDuration) day complete")
                            .font(.caption)
                    } else if event.showPercentages {
                        Text("\(percentComplete)% complete")
                            .font(.caption)
                    }
                }
                if event.showTotals && event.showPercentages {
                    Text(event.remainingDuration != 1
                            ? "\(event.remainingDuration) days (\(percentRemaining)%) left"
                            : "\(event.remainingDuration) day (\(percentRemaining)%) left")
                        .font(.caption)
                } else if event.showTotals {
                    Text(event.remainingDuration != 1
                            ? "\(event.remainingDuration) days left"
                            : "\(event.remainingDuration) day left")
                        .font(.caption)
                } else if event.showPercentages {
                    Text("\(percentRemaining)% left")
                        .font(.caption)
                }
            }
            Spacer()
        }
    }
}

extension EventCellView: EventViewElements {

}

struct EventCellView_Previews: PreviewProvider {
    static var previews: some View {
        EventCellView(event: Event(title: "My Event"))
    }
}
