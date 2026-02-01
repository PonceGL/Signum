//
//  ContentView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import SwiftUI

enum AppFeature: Hashable {
    case workspace
    case history
    case settings
    case pdfTools
}

struct RootView: View {
    @State private var activeFeature: AppFeature = .workspace
    @State private var path = NavigationPath()
    @StateObject private var workspaceViewModel = WorkspaceViewModel()

    var body: some View {
        #if os(macOS)
            TabView(selection: $activeFeature) {

                // --- MÓDULO: MESA DE TRABAJO (Feature Principal) ---
                MainWorkspaceView(viewModel: workspaceViewModel)
                    .tabItem {
                        Label("Escáner", systemImage: "doc.viewfinder")
                    }
                    .tag(AppFeature.workspace)

                // --- MÓDULO: HISTORIAL (Placeholder para V4) ---
                Placeholder(someText: "History Placeholder View")
                    .tabItem {
                        Label(
                            "Historial",
                            systemImage: "clock.arrow.circlepath"
                        )
                    }
                    .tag(AppFeature.history)

                // --- MÓDULO: AJUSTES ---
                Placeholder(someText: "Ajustes del Sistema")
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    .tag(AppFeature.settings)
            }
        #else

            NavigationStack(path: $path) {
                VStack(spacing: 20) {
                    Text("Pantalla de Inicio / Dashboard")
                        .font(.title)
                    Button("Abrir Workspace Principal") {
                        path.append("workspace")
                    }
                }
                .navigationDestination(for: String.self) { value in
                    if value == "workspace" {
                        MainWorkspaceView()
                            .navigationBarHidden(true)
                    }
                }
            }
        #endif
    }
}

struct Placeholder: View {
    var someText: String
    var body: some View {
        Text(someText)
            .font(.title)
    }
}

#Preview {
    RootView()
}
