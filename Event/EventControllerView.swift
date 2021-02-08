//
//  EventControllerView.swift
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

struct EventControllerView: View {
    var event: Event

    var body: some View {
        EventView(event: event)
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                    }, label: {
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

struct EventControllerView_Previews: PreviewProvider {
    static var previews: some View {
        EventControllerView(event: Event(title: "My Event"))
    }
}
