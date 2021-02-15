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
                showDates
                showComplete
                showTotals
            }
            .font(.caption)
            Spacer()
        }
    }
}

extension EventCellView: EventViewElements {

}

struct EventCellView_Previews: PreviewProvider {
    static var previews: some View {
        EventCellView(event: Event(title: "My Event", showRemainingDaysOnly: true))
    }
}
