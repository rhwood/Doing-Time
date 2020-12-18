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
        VStack {
            EventView(event: event)
            HStack {
                Spacer()
                Button(action: {
                    // show event settings
                }, label: {
                    Image(systemName: "gear")
                        .foregroundColor(Color(red: 0, green: 0.258, blue: 0.145, opacity: 1.0))
                })
            }
        }
        .padding()
    }
}

struct EventControllerView_Previews: PreviewProvider {
    static var previews: some View {
        EventControllerView(event: Event())
    }
}
