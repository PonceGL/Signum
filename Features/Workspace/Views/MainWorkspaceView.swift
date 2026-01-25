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
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    init(viewModel: WorkspaceViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? WorkspaceViewModel())
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // COLUMNA 1: Sidebar - Listado de Archivos
            WorkspaceSidebarView(viewModel: viewModel)
                .navigationTitle("Documentos")

        } content: {
            // COLUMNA 2: Centro - Visor de PDF
            if let document = viewModel.selectedDocument {
                 PDFPreviewView(document: document)
            } else {
                SignumEmptyStateView(
                    title: "Sin Selección",
                    systemImage: "doc.viewfinder",
                    description: "Selecciona un documento para visualizarlo."
                )
            }

        } detail: {
            // COLUMNA 3: Derecha - Panel de Edición
            if let document = viewModel.selectedDocument {
                DocumentInspectorView(document: document, viewModel: viewModel)
            } else {
                Text("Detalles del archivo")
                    .foregroundColor(.secondary)
            }
        }
        // Soporte para Drop de archivos en toda la vista
        .onDrop(of: [.pdf], isTargeted: nil) { providers in
            // TODO: Lógica para procesar el drop (la implementaremos a detalle)
            return true
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

