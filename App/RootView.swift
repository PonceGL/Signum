//
//  ContentView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI

struct RootView: View {

    private let appName: String

    init() {
        let appName = EnvironmentManager.shared.get(.appName)

        self.appName = appName
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text(appName)
                    .font(.largeTitle)
                    .bold()

                Text("Ready for Legal Processing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    RootView()
}
