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
                .tag(doc.id)
                .contextMenu {
                    Button {
                        // TODO: Reveal in Finder
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
                    Button(role: .destructive, action: viewModel.clearWorkspace)
                    {
                        Label("Limpiar", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.documents.isEmpty)

                    Spacer()

                    Button {
                        Task { await viewModel.startBatchProcessing() }
                    } label: {
                        Label("Analizar", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        viewModel.documents.isEmpty || viewModel.isProcessing
                    )
                }
                .padding()
            }
            .background(Color.signumSecondaryBackground)
        }
        .toolbar {
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
