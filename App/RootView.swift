//
//  ContentView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI

struct RootView: View {
    @State private var selectedRoute: AppRoute? = .dashboard

    private let appName: String

    init() {
        let appName = EnvironmentManager.shared.get(.appName)

        self.appName = appName
    }

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
    }

    private var sidebarContent: some View {
        List(AppRoute.allCases, selection: $selectedRoute) { route in
            NavigationLink(value: route) {
                Label(route.title, systemImage: route.iconName)
                    .font(.headline)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle(appName)
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var detailContent: some View {
        if let selectedRoute {
            switch selectedRoute {
            case .dashboard:
                Text("Dashboard Placeholder")
            case .scanner:
                Text("Scanner Placeholder")
            case .history:
                Text("History Placeholder")
            case .settings:
                Text("Settings Placeholder")
            }
        } else {

            ContentUnavailableView(
                "Selecciona una opción",
                systemImage: "sidebar.left",
                description: Text(
                    "Elige una herramienta del menú para comenzar."
                )
            )
        }
    }

}

#Preview {
    RootView()
}
