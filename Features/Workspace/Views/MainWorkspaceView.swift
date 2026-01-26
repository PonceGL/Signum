//
//  MainWorkspaceView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct MainWorkspaceView: View {
    @StateObject var viewModel: WorkspaceViewModel

    @State private var columnVisibility: NavigationSplitViewVisibility =
        .detailOnly
    @State private var isInspectorPresented: Bool = true
    @State private var isFileImporterPresented: Bool = false

    init(viewModel: WorkspaceViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? WorkspaceViewModel()
        )
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // COLUMNA 1: SIDEBAR
            if !viewModel.documents.isEmpty {
                WorkspaceSidebarView(viewModel: viewModel)
                    .navigationSplitViewColumnWidth(
                        min: 250,
                        ideal: 300,
                        max: 350
                    )
            } else {
                SignumEmptyStateView(
                    title: "Mesa Vacía",
                    systemImage: "doc.viewfinder",
                    description: "Arrastra archivos para comenzar.",
                ).navigationSplitViewColumnWidth(
                    min: 250,
                    ideal: 300,
                    max: 350
                )
            }

        } detail: {
            // COLUMNA 2: CONTENIDO PRINCIPAL
            ZStack {
                if let document = viewModel.selectedDocument {
                    PDFPreviewView(document: document)
                } else {
                    SignumEmptyStateView(
                        title: "Mesa Vacía",
                        systemImage: "doc.viewfinder",
                        description: "Arrastra archivos para comenzar.",
                        actionLabel: "Seleccionar Archivos",
                        action: { isFileImporterPresented = true }
                    )
                }
            }
            .toolbar {
                if !viewModel.documents.isEmpty {
                    #if !os(macOS)
                        ToolbarItem(placement: .topBarLeading) {
                            if columnVisibility == .detailOnly {
                                Button {
                                    toggleSidebar()
                                } label: {
                                    Label(
                                        "Mostrar Documentos",
                                        systemImage: "sidebar.left"
                                    )
                                }
                                .transition(
                                    .move(edge: .leading).combined(
                                        with: .opacity
                                    )
                                )
                            }
                        }
                    #endif

                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isInspectorPresented.toggle()
                        } label: {
                            Label("Inspector", systemImage: "sidebar.right")
                        }
                    }
                }
            }
            .signumInspector(isPresented: inspectorBinding) {
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
                .modifier(
                    InspectorWidthModifier(min: 220, ideal: 250, max: 360)
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .signumSidebarToggle(hidden: viewModel.documents.isEmpty)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.addFiles(from: urls)
            case .failure(let error):
                // TODO: Implementar gestión de errores mediante un Toast o Alerta
                print(
                    "Error al seleccionar archivos: \(error.localizedDescription)"
                )
            }
        }
        .animation(
            .spring(response: 0.4, dampingFraction: 0.8),
            value: columnVisibility
        )
        .onSignumChange(of: viewModel.documents.count) { oldValue, newValue in
            let isEmpty = (newValue == 0)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                columnVisibility = isEmpty ? .detailOnly : .all
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                columnVisibility =
                    viewModel.documents.isEmpty ? .detailOnly : .all
            }
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

    private func toggleSidebar() {
        withAnimation {
            columnVisibility =
                (columnVisibility == .detailOnly) ? .all : .detailOnly
        }
    }
}

struct InspectorWidthModifier: ViewModifier {
    let min: CGFloat
    let ideal: CGFloat
    let max: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            content.inspectorColumnWidth(min: min, ideal: ideal, max: max)
        } else {
            content.frame(minWidth: min, idealWidth: ideal, maxWidth: max)
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
