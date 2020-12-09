//
//  AppSettingsView.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-20.
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
import MessageUI

struct AppSettingsView: View {

    @State var result: Result<MFMailComposeResult, Error>?
    @State var isShowingMailView = false

    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "UNK"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "UNK"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "UNK"

    var body: some View {
        List {
            Section(header: Text("About \(product)"), footer: Text("\(product) version \(version) (\(build))")) {
                Button("Send Feedback", action: {
                    self.isShowingMailView.toggle()
                }).disabled(!MFMailComposeViewController.canSendMail())
                .sheet(isPresented: $isShowingMailView, content: {
                    MailView(result: self.$result)
                })
                NavigationLink(destination: AboutView()) { Text("Alexandria Software")
                }
            }
            Section(header: Text("Credits")) {
                Link(destination: URL(string: "http://axsw.co/fuCJn9")!) {
                    HStack {
                        Text("Dain Kaplan").foregroundColor(.primary)
                        Spacer()
                        Text("Chartreuse")
                    }
                }
                Link(destination: URL(string: "http://axsw.co/11IOfOC")!) {
                    HStack {
                        Text("Glyphish").foregroundColor(.primary)
                        Spacer()
                        Text("Icons")
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView()
    }
}
