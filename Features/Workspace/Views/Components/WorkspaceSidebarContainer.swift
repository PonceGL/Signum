//
//  WorkspaceSidebarContainer.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 26/01/26.
//

import SwiftUI

struct WorkspaceSidebarContainer: View {
    @ObservedObject var viewModel: WorkspaceViewModel

    var body: some View {
        Group {
            if !viewModel.documents.isEmpty {
                WorkspaceSidebarView(viewModel: viewModel)
            } else {
                SignumEmptyStateView(
                    title: "Mesa Vacía",
                    systemImage: "doc.viewfinder",
                    description: "Arrastra archivos para comenzar."
                )
            }
        }
        .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
    }
}

#Preview("Mesa Vacía") {
    let vm = WorkspaceViewModel()
    vm.documents = []
    return WorkspaceSidebarContainer(viewModel: vm)
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
    // Agregamos el mock a la lista
    vm.documents = [.mock]
    vm.selectedDocumentID = vm.documents.first?.id

    return WorkspaceSidebarContainer(viewModel: vm)
}

#Preview("Procesando") {
    let vm = WorkspaceViewModel()
    var doc = LegalDocument.mock
    doc.status = .analyzing
    vm.documents = [doc]
    vm.isProcessing = true
    vm.totalProgress = 0.5

    return WorkspaceSidebarContainer(viewModel: vm)
}
