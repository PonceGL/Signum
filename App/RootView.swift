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
    case pdfTools  // Placeholder para V3
}

struct RootView: View {
    @State private var activeFeature: AppFeature = .workspace
    @StateObject private var workspaceViewModel = WorkspaceViewModel()

    var body: some View {
        // En iPadOS 26, TabView es el estándar para navegación de alto nivel
        // que no interfiere con los SplitViews internos de cada feature.
        TabView(selection: $activeFeature) {

            // --- MÓDULO: MESA DE TRABAJO (Feature Principal) ---
            MainWorkspaceView(viewModel: workspaceViewModel)
                .tabItem {
                    Label("Escáner", systemImage: "doc.viewfinder")
                }
                .tag(AppFeature.workspace)

            // --- MÓDULO: HISTORIAL (Placeholder para V4) ---
            // Solo se renderiza si el usuario tiene acceso (Modularidad)
            Placeholder(someText: "History Placeholder View")
                .tabItem {
                    Label("Historial", systemImage: "clock.arrow.circlepath")
                }
                .tag(AppFeature.history)

            // --- MÓDULO: AJUSTES ---
            Placeholder(someText:"Ajustes del Sistema")
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
                .tag(AppFeature.settings)
        }
        // iPadOS 26: Permite que la TabBar sea "Liquid Glass" en la parte superior
//        .tabViewStyle(.sidebarAdaptable)
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
