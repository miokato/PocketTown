//
//  PocketTownWidgetLiveActivity.swift
//  PocketTownWidget
//
//  Created by mio kato on 2025/06/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PocketTownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PocketTownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PocketTownWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PocketTownWidgetAttributes {
    fileprivate static var preview: PocketTownWidgetAttributes {
        PocketTownWidgetAttributes(name: "World")
    }
}

extension PocketTownWidgetAttributes.ContentState {
    fileprivate static var smiley: PocketTownWidgetAttributes.ContentState {
        PocketTownWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PocketTownWidgetAttributes.ContentState {
         PocketTownWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PocketTownWidgetAttributes.preview) {
   PocketTownWidgetLiveActivity()
} contentStates: {
    PocketTownWidgetAttributes.ContentState.smiley
    PocketTownWidgetAttributes.ContentState.starEyes
}
