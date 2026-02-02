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

    var onUndo: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onPdfTools: (() -> Void)? = nil

    var body: some ToolbarContent {
        if !viewModel.documents.isEmpty {
            ToolbarItem(placement: .principal) { Spacer() }

            ToolbarItemGroup(placement: .primaryAction) {
                ControlGroup {
                    if let onUndo = onUndo {
                        Button(action: onUndo) {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        }
                        
                    }
                    
                    if let onShare = onShare {
                        Button(action: onShare) {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                    }

                    if let onPdfTools = onPdfTools {
                        Button(action: onPdfTools) {
                            Label("Settings", systemImage: "gear")
                        }
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
                        Label("Edit", systemImage: horizontalSizeClass == .compact ? "pencil" : "sidebar.right")
                    }
                }
            #endif
        }
    }
}
