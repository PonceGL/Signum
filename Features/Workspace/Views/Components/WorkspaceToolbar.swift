//
//  WorkspaceToolbar.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 29/01/26.
//

import SwiftUI

struct WorkspaceToolbar: ToolbarContent {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Binding var isInspectorPresented: Bool

    var onUndo: () -> Void
    var onShare: () -> Void
    var onMore: () -> Void

    var body: some ToolbarContent {
        if !viewModel.documents.isEmpty {
            ToolbarItem(placement: .principal) { Spacer() }

            ToolbarItemGroup(placement: .primaryAction) {
                ControlGroup {
                    Button(action: onUndo) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }

                    Button(action: onShare) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(action: onMore) {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }

            #if !os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                        ) {
                            isInspectorPresented.toggle()
                        }
                    } label: {
                        Label("Edit", systemImage: "sidebar.right")
                    }
                }
            #endif
        }
    }
}
