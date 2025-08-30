//
//  iOS_WidgetBundle.swift
//  iOS Widget
//
//  Created by Brandon Lamer-Connolly on 8/30/25.
//

import WidgetKit
import SwiftUI

@main
struct iOS_WidgetBundle: WidgetBundle {
    var body: some Widget {
        iOS_Widget()
        iOS_WidgetControl()
        iOS_WidgetLiveActivity()
    }
}
