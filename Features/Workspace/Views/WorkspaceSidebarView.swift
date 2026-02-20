//
//  WorkspaceSidebarView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

struct WorkspaceSidebarView: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var onHistory: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            List(viewModel.documents, selection: $viewModel.selectedDocumentID)
            { doc in
                FileRowView(
                    document: doc,
                    isSelected: viewModel.selectedDocumentID == doc.id
                )
                .id("\(doc.id)-\(doc.userEditedName)")
                .tag(doc.id)
                .contextMenu {
                    Button {
                        // TODO: Reveal in Finder iOS
                        print("Reveal in Finder doc: \(doc)")
                        #if os(macOS)
                            NSWorkspace.shared.activateFileViewerSelecting([
                                doc.originalURL
                            ])
                        #endif
                    } label: {
                        Label("Ver en carpeta", systemImage: "folder")
                    }
                }
            }
            .listStyle(.sidebar)

            VStack(spacing: 12) {
                if viewModel.isProcessing {
                    ProgressView(value: viewModel.totalProgress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                }

                HStack {
                    SignumButton(
                        title: "Limpiar",
                        role: .destructive,
                        iconLeft: "trash",
                        backgroundColor: .red,
                        isDisabled: (viewModel.documents.isEmpty
                            || viewModel.isProcessing)
                    ) {
                        viewModel.clearWorkspace()
                    }
                    .controlSize(.large)
                    //                    .keyboardShortcut(.return, modifiers: []) // TODO:

                    Spacer()

                    SignumButton(
                        title: "Analizar",
                        iconLeft: "play.fill",
                        isDisabled: (viewModel.documents.isEmpty
                            || viewModel.isProcessing)
                    ) {
                        Task { await viewModel.startBatchProcessing() }
                    }
                    .controlSize(.large)
                    //                    .keyboardShortcut(.return, modifiers: []) // TODO:
                }
                .padding()
            }
            .background(Color.signumSecondaryBackground)
        }
        .toolbar {
            #if !os(macOS)
                if !viewModel.documents.isEmpty {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        ControlGroup {
                            if let onHistory = onHistory {
                                Button(action: onHistory) {
                                    Label(
                                        AppRoute.history.title,
                                        systemImage: AppRoute.history.iconName
                                    )
                                }

                            }

                        }
                    }
                }
            #endif
        }
    }
}

#Preview {
    let vm = WorkspaceViewModel()
    vm.addFiles(from: [
        URL(fileURLWithPath: "Documento1.pdf"),
        URL(fileURLWithPath: "Documento2.pdf"),
    ])
    return WorkspaceSidebarView(viewModel: vm)
        .frame(width: 300)
}
