//
//  SettingsViewHostingController.swift
//  Doing Time
//
//  Created by Randall Wood on 2020-11-20.
//

import SwiftUI

class SettingsViewHostingController: UIHostingController<SettingsView> {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsView())
    }
}
