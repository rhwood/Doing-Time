//
//  MainView.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-28.
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

struct MainView: View {

    @EnvironmentObject private var model: EventsModel
    /// part of hack to work around bottomBar not reappearing when navigating back up the stack
    @State private var isShown = true
    /// part of hack to work around bottomBar not reappearing when navigating back up the stack
    @State private var refresh = UUID()

    var body: some View {
        NavigationView {
            List {
                ForEach(model.events) { event in
                    NavigationLink(destination: EventPageView(event: event)
                                    .onDisappear(perform: destinationOnDisappear)
                                    .onAppear(perform: destinationOnAppear)) {
                        EventCellView(event: event)
                    }
                }
            }
            .onAppear {
                isShown = true
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        print("New Event requested!")
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("New Event")
                    }).help("Create a new event.")
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AppSettingsView()
                                    .onDisappear(perform: destinationOnDisappear)
                                    .onAppear(perform: destinationOnAppear)) {
                        Image(systemName: "info.circle")
                    }
                    .help("About Doing Time.")
                }
            }
            .id(refresh)
        }
        .accentColor(Color("AccentColor"))
    }

    /// part of hack to work around bottomBar not reappearing when navigating back up the stack
    private func destinationOnDisappear() {
        if isShown {
            refresh = UUID()
        }
    }

    /// part of hack to work around bottomBar not reappearing when navigating back up the stack
    private func destinationOnAppear() {
        isShown = false
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(EventsModel.preview)
    }
}
