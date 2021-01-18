//
//  CDEvent+CoreDataProperties.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-12-28.
//
//

import Foundation
import CoreData


extension CDEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDEvent> {
        return NSFetchRequest<CDEvent>(entityName: "Event")
    }

    @NSManaged public var backgroundColor: Data?
    @NSManaged public var completedColor: Data?
    @NSManaged public var end: Date?
    @NSManaged public var includeEnd: Bool
    @NSManaged public var remainingColor: Data?
    @NSManaged public var showDates: Bool
    @NSManaged public var showPercentages: Bool
    @NSManaged public var showRemainingDaysOnly: Bool
    @NSManaged public var showTotals: Bool
    @NSManaged public var start: Date?
    @NSManaged public var title: String?
    @NSManaged public var todayIs: Int32

}

extension CDEvent : Identifiable {

}
