//
//  SettingsView.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-20.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
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
        SettingsView()
    }
}
