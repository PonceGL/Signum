//
//  SignumApp.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI

@main
struct SignumApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                #if os(macOS)
                    .frame(minWidth: 1200, minHeight: 700)
                #endif
        }
        #if os(macOS)
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
        #endif
    }
}
