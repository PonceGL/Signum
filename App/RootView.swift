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

enum AppDestination: Identifiable {
    case workspace
    case history
    case settings
    case onboarding
    case userProfile

    var id: Self { self }
}

struct RootView: View {
    @StateObject private var workspaceViewModel = WorkspaceViewModel()

    @State private var activeDestination: AppDestination? = .workspace
    @State private var activeFeature: AppDestination = .workspace

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

            MainWorkspaceView(
                viewModel: workspaceViewModel,
                onOpenSettings: { navigateTo(.settings) },
                onOpenProfile: { navigateTo(.userProfile) }
            )
            .fullScreenCover(item: $activeDestination) { destination in
                switch destination {
                case .settings:
                    NavigationStack {
                        Placeholder(someText: "Vista de Ajustes")
                            .toolbar {
                                Button(action: {
                                    navigateTo(nil)
                                }) {
                                    Label("Listo", systemImage: "xmark.circle")
                                }
                            }
                    }

                case .userProfile:
                    NavigationStack {
                        Placeholder(someText: "Perfil de Usuario")
                            .navigationTitle("Mi Cuenta")
                            .toolbar {
                                Button(action: {
                                    navigateTo(nil)
                                }) {
                                    Label("Listo", systemImage: "xmark.circle")
                                }
                            }
                    }

                case .onboarding:
                    Placeholder(someText: "Bienvenido")
                }
            }
        #endif

    }

    private func navigateTo(_ destination: AppDestination?) {
        activeDestination = destination
    }
}

struct Placeholder: View {
    var someText: String
    var body: some View {
        VStack {
            Text(someText)
                .font(.title)
        }
    }
}

#Preview {
    RootView()
}
