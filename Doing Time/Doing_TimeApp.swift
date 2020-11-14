//
//  Doing_TimeApp.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-14.
//

import SwiftUI

@main
struct Doing_TimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
