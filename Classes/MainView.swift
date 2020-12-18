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

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    EventView(event: Event())
                    EventView(event: Event())
                    EventView(event: Event())
                }
            }
            HStack {
                Button(action: {
                    // show event settings
                    // ideally show menu of event ("edit") and app ("about / info") settings
                }, label: {
                    Image(systemName: "gear")
                        .foregroundColor(Color(red: 0, green: 0.258, blue: 0.145, opacity: 1.0))
                })
                Spacer()
                Button(action: {
                    // add new event
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(red: 0, green: 0.258, blue: 0.145, opacity: 1.0))
                })
            }
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
