//
//  EventViewElements.swift
//  Doing Time
//
//  Created by Randall Wood on 2/9/21.
//

import Foundation
import SwiftUI

protocol EventViewElements {
    var event: Event { get set }
    var percentComplete: String { get }
    var percentRemaining: String { get }
    func format(_ percent: Float) -> String
    var pieChart: AnyView { get }
    var showDates: AnyView { get }
}

extension EventViewElements {

    var percentComplete: String {
        return format(Float(100) * event.completedPercentage)
    }
    var percentRemaining: String {
        return format(Float(100) * event.remainingPercentage)
    }

    var pieChart: AnyView {
        AnyView(PieChart(slices: [
            PieChartSlice(start: 0.0,
                          end: event.completedPercentage,
                          color: event.completedColor),
            PieChartSlice(start: event.completedPercentage,
                          end: event.todayPercentage,
                          color: event.backgroundColor),
            PieChartSlice(start: event.completedPercentage + event.todayPercentage,
                          end: 1.0,
                          color: event.remainingColor)
        ]))
    }

    var showDates: AnyView {
        let startDate = format(event.start)
        let endDate = format(event.end)
        return AnyView(Text("\(startDate) to \(endDate)"))
    }

    func format(_ percent: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: percent))!
    }

    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
