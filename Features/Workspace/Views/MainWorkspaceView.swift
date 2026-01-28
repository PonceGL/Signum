//
//  MainWorkspaceView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct LayoutConfig {
    static let sideBarWidth: (min: CGFloat, ideal: CGFloat, max: CGFloat) = (
        220, 300, 400
    )
    static let mainContentWidth: (min: CGFloat, ideal: CGFloat, max: CGFloat) =
        (450, 600, .infinity)
}

@MainActor
struct MainWorkspaceView: View {
    @StateObject var viewModel: WorkspaceViewModel

    @State private var columnVisibility: NavigationSplitViewVisibility =
        .detailOnly
    @State private var isInspectorPresented: Bool = true
    @State private var isFileImporterPresented: Bool = false

    init(viewModel: WorkspaceViewModel? = nil) {
        let vm = viewModel ?? WorkspaceViewModel()
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        #if os(macOS)
            HSplitView {
                if !viewModel.documents.isEmpty {
                    WorkspaceSidebarContainer(viewModel: viewModel)
                        .frame(
                            minWidth: 320,
                            idealWidth: 400,
                            maxWidth: 500,
                            maxHeight: .infinity
                        )
                }

                WorkspaceDetailContainer(
                    viewModel: viewModel,
                    isFileImporterPresented: $isFileImporterPresented
                )
                .frame(
                    minWidth: LayoutConfig.mainContentWidth.min,
                    idealWidth: LayoutConfig.mainContentWidth.ideal,
                    maxWidth: LayoutConfig.mainContentWidth.max,
                    maxHeight: .infinity
                )
                .navigationTitle("")
                .toolbarRole(.editor)
                .toolbar {
                    workspaceToolbar
                }

                if let document = viewModel.selectedDocument {
                    Group {
                        if let document = viewModel.selectedDocument {
                            DocumentInspectorView(
                                document: document,
                                viewModel: viewModel
                            )
                        } else {
                            Text("Selecciona un archivo")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(
                        minWidth: 320,
                        idealWidth: 400,
                        maxWidth: 500,
                        maxHeight: .infinity
                    )
                }

            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true
            ) { result in
                handleImport(result: result)
            }
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: columnVisibility
            )
            .onSignumChange(of: viewModel.documents.count) { _, newValue in
                let isEmpty = (newValue == 0)

                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8))
                    {
                        updateColumnVisibility(isEmpty: isEmpty)
                    }
                }
            }
            .onAppear {
                updateColumnVisibility(isEmpty: viewModel.documents.isEmpty)
            }

        #else
            NavigationSplitView(columnVisibility: $columnVisibility) {
                WorkspaceSidebarContainer(viewModel: viewModel)
                    .navigationSplitViewColumnWidth(
                        min: LayoutConfig.sideBarWidth.min,
                        ideal: LayoutConfig.sideBarWidth.ideal,
                        max: LayoutConfig.sideBarWidth.max
                    )
            } detail: {
                WorkspaceDetailContainer(
                    viewModel: viewModel,
                    isFileImporterPresented: $isFileImporterPresented
                )
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarRole(.editor)
                .toolbar {
                    workspaceToolbar
                }

            }
            .inspector(isPresented: inspectorBinding) {
                Group {
                    if let document = viewModel.selectedDocument {
                        DocumentInspectorView(
                            document: document,
                            viewModel: viewModel
                        )
                    } else {
                        Text("Selecciona un archivo")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationSplitViewColumnWidth(
                    min: LayoutConfig.sideBarWidth.min,
                    ideal: LayoutConfig.sideBarWidth.ideal,
                    max: LayoutConfig.sideBarWidth.max
                )
            }
            .navigationSplitViewStyle(.balanced)
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true
            ) { result in
                handleImport(result: result)
            }
            .animation(
                .spring(response: 0.4, dampingFraction: 0.8),
                value: columnVisibility
            )
            .onSignumChange(of: viewModel.documents.count) { _, newValue in
                let isEmpty = (newValue == 0)

                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8))
                    {
                        updateColumnVisibility(isEmpty: isEmpty)
                    }
                }
            }
            .onAppear {
                updateColumnVisibility(isEmpty: viewModel.documents.isEmpty)
            }
        #endif

    }

    @ToolbarContentBuilder
    private var workspaceToolbar: some ToolbarContent {
        if !viewModel.documents.isEmpty {
            ToolbarItem(placement: .principal) { Spacer() }
            ToolbarItemGroup(placement: .primaryAction) {
                ControlGroup {

                    Button {
                        // TODO:
                    } label: {

                        Label(

                            "Undo",

                            systemImage: "arrow.uturn.backward"

                        )

                    }

                    Button {
                        // TODO:
                    } label: {

                        Label(

                            "Share",

                            systemImage: "square.and.arrow.up"

                        )

                    }

                    Button {
                        // TODO:
                    } label: {

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

    private var inspectorBinding: Binding<Bool> {
        Binding(
            get: {
                isInspectorPresented && !viewModel.documents.isEmpty
                    && !viewModel.isProcessing
            },
            set: { isInspectorPresented = $0 }
        )
    }

    private func updateColumnVisibility(isEmpty: Bool) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            columnVisibility = isEmpty ? .detailOnly : .all
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            viewModel.addFiles(from: urls)
        case .failure(let error):
            print(
                "Error al seleccionar archivos: \(error.localizedDescription)"
            )
        }
    }
}

#Preview("Mesa Vacía") {
    MainWorkspaceView()
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
    // Agregamos el mock a la lista
    vm.documents = [.mock]
    vm.selectedDocumentID = vm.documents.first?.id

    return MainWorkspaceView(viewModel: vm)
}

#Preview("Procesando") {
    let vm = WorkspaceViewModel()
    var doc = LegalDocument.mock
    doc.status = .analyzing
    vm.documents = [doc]
    vm.isProcessing = true
    vm.totalProgress = 0.5

    return MainWorkspaceView(viewModel: vm)
}
