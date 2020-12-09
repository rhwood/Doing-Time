//
//  AboutView.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-18.
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

struct AboutView: View {

    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "UNK"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "UNK"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "UNK"

    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "http://axsw.co/fufMuq")!) {
                    HStack {
                        Spacer()
                        Image("ASlogo1-64x192")
                        Spacer()
                    }
                }
            }
            Section(footer: Text("\(product) version \(version) (\(build))")) {
                Link(destination: URL(string: "http://axsw.co/icgDcu")!) {
                    HStack {
                        Text("Web").foregroundColor(.primary)
                        Spacer()
                        Text("alexandriasoftware.com")
                    }
                }
                Link(destination: URL(string: "http://axsw.co/f4dzGc")!) {
                    HStack {
                        Text("Twitter").foregroundColor(.primary)
                        Spacer()
                        Text("@alexandriasw")
                    }
                }
                Link(destination: URL(string: "http://axsw.co/eaDeKF")!) {
                    HStack {
                        Text("Facebook").foregroundColor(.primary)
                        Spacer()
                        Text("Like Us!")
                    }
                }
                Link(destination: URL(string: "http://axsw.co/fO5256")!) {
                    HStack {
                        Text("Support").foregroundColor(.primary)
                        Spacer()
                        Text("Contact Us")
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
