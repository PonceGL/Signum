//
//  WorkspaceToolbar.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 29/01/26.
//

import SwiftUI

struct WorkspaceToolbar: ToolbarContent {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var isInspectorPresented: Bool

    var onOpenProfile: (() -> Void)? = nil
    var onPdfTools: (() -> Void)? = nil

    var body: some ToolbarContent {
        if !viewModel.documents.isEmpty {
            ToolbarItem(placement: .principal) { Spacer() }

            ToolbarItemGroup(placement: .primaryAction) {
                ControlGroup {

                    if let onPdfTools = onPdfTools {
                        Button(action: onPdfTools) {
                            Label(
                                AppRoute.pdfTools.title,
                                systemImage: AppRoute.pdfTools.iconName
                            )
                        }
                    }

                    if let onOpenProfile = onOpenProfile {
                        Button(action: onOpenProfile) {
                            Label(
                                AppRoute.userProfile.title,
                                systemImage: AppRoute.userProfile.iconName
                            )
                        }
                    }

                }
            }

            #if !os(macOS)
                if horizontalSizeClass != .compact {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            withAnimation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                            ) {
                                isInspectorPresented.toggle()
                            }
                        } label: {
                            Label(
                                "Edit",
                                systemImage: "sidebar.right"
                            )
                        }
                    }
                }
            #endif
        }
    }
}
