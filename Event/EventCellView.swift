//
//  EventCellView.swift
//  Doing Time
//
//  Created by Randall Wood on 2/7/21.
//

import SwiftUI

struct EventCellView: View {
    
    var event: Event
    var startDate: String {
        return format(event.start)
    }
    var endDate: String {
        return format(event.end)
    }
    var percentComplete: String {
        return format(Float(100) * event.completedPercentage)
    }
    var percentRemaining: String {
        return format(Float(100) * event.remainingPercentage)
    }

    var body: some View {
        HStack(alignment: .center) {
            PieChart(slices: [
                PieChartSlice(start: 0.0,
                              end: event.completedPercentage,
                              color: event.completedColor),
                PieChartSlice(start: event.completedPercentage,
                              end: event.todayPercentage,
                              color: event.backgroundColor),
                PieChartSlice(start: event.completedPercentage + event.todayPercentage,
                              end: 1.0,
                              color: event.remainingColor)
            ])
            .frame(width: 44, height: 44, alignment: .center)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                if event.showDates {
                    Text("\(startDate) to \(endDate)")
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

    func format(_ percent: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: percent))!
    }

    func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct EventCellView_Previews: PreviewProvider {
    static var previews: some View {
        EventCellView(event: Event(title: "My Event"))
    }
}
