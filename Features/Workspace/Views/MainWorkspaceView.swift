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
        Group {
            #if os(macOS)
                HSplitView {
                    sidebarView

                    detailView

                    if isInspectorPresented && viewModel.selectedDocument != nil
                    {
                        inspectorView
                    }
                }
            #else
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    sidebarView
                        .navigationSplitViewColumnWidth(
                            min: LayoutConfig.sideBarWidth.min,
                            ideal: LayoutConfig.sideBarWidth.ideal,
                            max: LayoutConfig.sideBarWidth.max
                        )
                } detail: {
                    detailView
                }
                .inspector(isPresented: inspectorBinding) {
                    inspectorView
                        .navigationSplitViewColumnWidth(
                            min: LayoutConfig.sideBarWidth.min,
                            ideal: LayoutConfig.sideBarWidth.ideal,
                            max: LayoutConfig.sideBarWidth.max
                        )
                }
                .navigationSplitViewStyle(.balanced)
            #endif
        }
        .applyWorkspaceBehavior(
            viewModel: viewModel,
            columnVisibility: $columnVisibility,
            isFileImporterPresented: $isFileImporterPresented,
            onImport: handleImport
        )
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

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            viewModel.addFiles(from: urls)
        case .failure(let error):
            print(
                "Error al seleccionar archivos: \(error.localizedDescription)"
            )
            viewModel.importErrorMessage =
                "Error de sistema al seleccionar archivos: \(error.localizedDescription)"
        }
    }
}

extension MainWorkspaceView {

    @ViewBuilder
    fileprivate var sidebarView: some View {
        if !viewModel.documents.isEmpty {
            WorkspaceSidebarContainer(viewModel: viewModel)
                .frame(
                    minWidth: LayoutConfig.sideBarWidth.min,
                    idealWidth: LayoutConfig.sideBarWidth.ideal,
                    maxWidth: LayoutConfig.sideBarWidth.max,
                    maxHeight: .infinity
                )
        } else {
            #if !os(macOS)
                detailView
            #endif
        }
    }

    @ViewBuilder
    fileprivate var detailView: some View {
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
            WorkspaceToolbar(
                viewModel: viewModel,
                isInspectorPresented: $isInspectorPresented,
                onUndo: { print("Undo tap") },
                onShare: { print("Share tap") },
                onMore: { print("More tap") }
            )
        }
    }

    @ViewBuilder
    fileprivate var inspectorView: some View {
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
            minWidth: LayoutConfig.sideBarWidth.min,
            idealWidth: LayoutConfig.sideBarWidth.ideal,
            maxWidth: LayoutConfig.sideBarWidth.max,
            maxHeight: .infinity
        )
    }
}

#Preview("Mesa Vacía") {
    MainWorkspaceView()
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
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
