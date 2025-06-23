//
//  PocketTownWidgetBundle.swift
//  PocketTownWidget
//
//  Created by mio kato on 2025/06/24.
//

import WidgetKit
import SwiftUI

@main
struct PocketTownWidgetBundle: WidgetBundle {
    var body: some Widget {
        PocketTownWidget()
        PocketTownWidgetControl()
        PocketTownWidgetLiveActivity()
    }
}
