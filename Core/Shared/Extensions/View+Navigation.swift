//
//  View+Navigation.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 29/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceBehaviorModifier: ViewModifier {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Binding var isFileImporterPresented: Bool

    let onImport: (Result<[URL], Error>) -> Void

    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true,
                onCompletion: onImport
            )
            .onSignumChange(of: viewModel.documents.count) { _, newValue in
                updateVisibility(isEmpty: newValue == 0)
            }
            .onAppear {
                updateVisibility(isEmpty: viewModel.documents.isEmpty)
            }
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: columnVisibility
            )
            .withDocumentDropSupport(viewModel: viewModel)
    }

    private func updateVisibility(isEmpty: Bool) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                columnVisibility = isEmpty ? .detailOnly : .all
            }
        }
    }
}

extension View {
    func applyWorkspaceBehavior(
        viewModel: WorkspaceViewModel,
        columnVisibility: Binding<NavigationSplitViewVisibility>,
        isFileImporterPresented: Binding<Bool>,
        onImport: @escaping (Result<[URL], Error>) -> Void
    ) -> some View {
        self.modifier(
            WorkspaceBehaviorModifier(
                viewModel: viewModel,
                columnVisibility: columnVisibility,
                isFileImporterPresented: isFileImporterPresented,
                onImport: onImport
            )
        )
    }
}
