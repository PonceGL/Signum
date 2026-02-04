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

                MainWorkspaceView(viewModel: viewModel)
                    .tabItem {
                        Label(
                            AppRoute.scanner.title,
                            systemImage: AppRoute.scanner.iconName
                        )
                    }
                    .tag(AppRoute.scanner)
                    .toolbar {
                        if !viewModel.documents.isEmpty {
                            // LEFT SIDE (Leading)
                            ToolbarItem(placement: .navigation) {
                                Button(action: {}) {
                                    Label("Limoiar", systemImage: "trash")
                                }
                            }

                            ToolbarItem(placement: .navigation) {
                                Button(action: {}) {
                                    Label("Analizar", systemImage: "play.fill")
                                }
                            }

                            // RIGHT SIDE (Trailing)
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: {}) {
                                    Image(systemName: "plus")
                                }
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: {}) {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                    }

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
