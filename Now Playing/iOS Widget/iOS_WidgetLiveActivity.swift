//
//  iOS_WidgetLiveActivity.swift
//  iOS Widget
//
//  Created by Brandon Lamer-Connolly on 8/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct iOS_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct iOS_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: iOS_WidgetAttributes.self) { context in
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

extension iOS_WidgetAttributes {
    fileprivate static var preview: iOS_WidgetAttributes {
        iOS_WidgetAttributes(name: "World")
    }
}

extension iOS_WidgetAttributes.ContentState {
    fileprivate static var smiley: iOS_WidgetAttributes.ContentState {
        iOS_WidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: iOS_WidgetAttributes.ContentState {
         iOS_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: iOS_WidgetAttributes.preview) {
   iOS_WidgetLiveActivity()
} contentStates: {
    iOS_WidgetAttributes.ContentState.smiley
    iOS_WidgetAttributes.ContentState.starEyes
}
