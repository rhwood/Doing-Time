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

    let logoUrl = "http://axsw.co/fufMuq"
    let webUrl = "http://axsw.co/icgDcu"
    let twitterUrl = "http://axsw.co/f4dzGc"
    let facebookUrl = "http://axsw.co/eaDeKF"
    let supportUrl = "http://axsw.co/fO5256"
    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "UNK"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "UNK"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "UNK"

    var body: some View {
        List {
            Section {
                imageLink(destination: URL(string: logoUrl)!, image: "ASlogo1-64x192")
            }
            Section(footer: Text("\(product) version \(version) (\(build))")) {
                textLink(destination: URL(string: webUrl)!, primary: "Web", secondary: "alexandriasoftware.com")
                textLink(destination: URL(string: twitterUrl)!, primary: "Twitter", secondary: "@alexandriasw")
                textLink(destination: URL(string: facebookUrl)!, primary: "Facebook", secondary: "Like Us!")
                textLink(destination: URL(string: supportUrl)!, primary: "Support", secondary: "Contact Us")
            }
        }.listStyle(GroupedListStyle())
    }

    private func imageLink(destination: URL, image: String) -> some View {
        Link(destination: destination) {
            HStack {
                Spacer()
                Image(image)
                Spacer()
            }
        }
    }

    private func textLink(destination: URL, primary: String, secondary: String) -> some View {
        Link(destination: destination) {
            HStack {
                Text(primary).foregroundColor(.primary)
                Spacer()
                Text(secondary)
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
