//
//  Color+Extensions.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension Color {
    static var signumSecondaryBackground: Color {
        #if os(macOS)
            return Color(NSColor.windowBackgroundColor)
        #else
            return Color(UIColor.secondarySystemGroupedBackground)
        #endif
    }
}
