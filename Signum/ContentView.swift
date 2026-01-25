//
//  ContentView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI

struct ContentView: View {
    
    private let appName: String
    private let bundleId: String
    private let modeString: String
    
    init() {
        let appName = EnvironmentManager.shared.get(.appName)
        let bundleId = EnvironmentManager.shared.get(.bundleId)
        let modeString = EnvironmentManager.shared.isDebug ? "DEBUG (Dev)" : "RELEASE (Prod)"

        self.appName = appName
        self.bundleId = bundleId
        self.modeString = modeString
    }
    
    var body: some View {
        VStack {
            Text("📱 App Name: \(appName)")
            Text("🆔 Bundle ID: \(bundleId)")
            Text("🛠 Mode: \(modeString)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
