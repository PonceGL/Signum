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

    var onHistory: (() -> Void)? = nil
    var onPdfTools: (() -> Void)? = nil
    var onOpenProfile: (() -> Void)? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var isIPhone: Bool {
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom == .phone
        #else
            false
        #endif
    }

    var showInPhone: Bool {
        horizontalSizeClass == .compact && isIPhone
    }

    @State private var columnVisibility: NavigationSplitViewVisibility =
        .detailOnly
    @State private var isInspectorPresented: Bool = true
    @State private var isFileImporterPresented: Bool = false

    init(
        viewModel: WorkspaceViewModel? = nil,
        onHistory: (() -> Void)? = nil,
        onPdfTools: (() -> Void)? = nil,
        onOpenProfile: (() -> Void)? = nil
    ) {
        let vm = viewModel ?? WorkspaceViewModel()
        _viewModel = StateObject(wrappedValue: vm)
        self.onHistory = onHistory
        self.onPdfTools = onPdfTools
        self.onOpenProfile = onOpenProfile
    }

    var body: some View {
        Group {
            #if os(macOS)
                HSplitView {
                    if !viewModel.documents.isEmpty {
                        sidebarView
                    }

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
                        .presentationDetents([.medium, .large])
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
        .alert(item: $viewModel.importAlert) { alertConfig in
            createAlert(from: alertConfig)
        }
    }
    
    private func createAlert(from config: ImportAlert) -> Alert {
        if config.actions.count == 1 {
            // Alerta simple con un solo botón
            return Alert(
                title: Text(config.title),
                message: Text(config.message),
                dismissButton: .default(Text(config.actions[0].title), action: config.actions[0].handler)
            )
        } else {
            // Alerta con múltiples botones
            return Alert(
                title: Text(config.title),
                message: Text(config.message),
                primaryButton: alertButton(from: config.actions[0]),
                secondaryButton: alertButton(from: config.actions[1])
            )
        }
    }
    
    private func alertButton(from action: ImportAlert.AlertAction) -> Alert.Button {
        switch action.style {
        case .cancel:
            return .cancel(Text(action.title), action: action.handler)
        case .destructive:
            return .destructive(Text(action.title), action: action.handler)
        case .default:
            return .default(Text(action.title), action: action.handler)
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
        WorkspaceSidebarContainer(
            viewModel: viewModel,
            isFileImporterPresented: $isFileImporterPresented,
            onHistory: onHistory,
        )
        .frame(
            minWidth: LayoutConfig.sideBarWidth.min,
            idealWidth: LayoutConfig.sideBarWidth.ideal,
            maxWidth: LayoutConfig.sideBarWidth.max,
            maxHeight: .infinity
        )

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
                onOpenProfile: onOpenProfile,
                onPdfTools: onPdfTools
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
                .padding()
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
