//
//  MacRootView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 01/02/26.
//

import SwiftUI

struct MacRootView: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    @State private var selectedRoute: AppRoute = .scanner

    var body: some View {
        #if os(macOS)
            TabView(selection: $selectedRoute) {

                MainWorkspaceView(
                    viewModel: viewModel,
                )
                .tabItem {
                    Label(
                        AppRoute.scanner.title,
                        systemImage: AppRoute.scanner.iconName
                    )
                }
                .tag(AppRoute.scanner)

                Placeholder(someText: AppRoute.pdfTools.title)
                    .tabItem {
                        Label(
                            AppRoute.pdfTools.title,
                            systemImage: AppRoute.pdfTools.iconName
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(AppRoute.pdfTools)

                Placeholder(someText: AppRoute.userProfile.title)
                    .tabItem {
                        Label(
                            AppRoute.userProfile.title,
                            systemImage: AppRoute.userProfile.iconName
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(AppRoute.userProfile)
            }
        #endif
    }
}
