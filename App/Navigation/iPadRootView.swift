//
//  iPadRootView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 01/02/26.
//

import SwiftUI

struct iPadRootView: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    @State private var activeRoute: AppRoute?

    var body: some View {
        #if os(iOS)
            MainWorkspaceView(
                viewModel: viewModel,
//                onHistory: {
//                    print("on History")
//                },
                onPdfTools: {
                    navigateTo(.pdfTools)
                },
                onOpenProfile: { navigateTo(.userProfile) }
            )
            .fullScreenCover(item: $activeRoute) { destination in
                switch destination {
                case .scanner:
                    EmptyView()

                case .pdfTools:
                    ModalWrapper(
                        title: destination.title,
                        iconLabel: "Listo",
                        iconName: "xmark.circle",
                        onAction: dismiss
                    ) {
                        Placeholder(someText: AppRoute.pdfTools.title)
                    }

                case .userProfile:
                    ModalWrapper(
                        title: destination.title,
                        iconLabel: "Listo",
                        iconName: "xmark.circle",
                        onAction: dismiss
                    ) {
                        Placeholder(someText: AppRoute.userProfile.title)
                    }

                case .history:
                    ModalWrapper(
                        title: destination.title,
                        iconLabel: "Listo",
                        iconName: "xmark.circle",
                        onAction: dismiss
                    ) {
                        Placeholder(someText: AppRoute.history.title)
                    }
                }
            }
        #endif
    }

    private func dismiss() {
        navigateTo(nil)
    }

    private func navigateTo(_ destination: AppRoute?) {
        activeRoute = destination
    }
}

private struct ModalWrapper<Content: View>: View {
    let title: String
    let iconLabel: String
    let iconName: String
    let onAction: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbar {
                    Button(action: onAction) {
                        Label(
                            iconLabel,
                            systemImage: iconName
                        )
                    }
                }
        }
    }
}
