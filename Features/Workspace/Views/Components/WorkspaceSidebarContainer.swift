//
//  WorkspaceSidebarContainer.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 26/01/26.
//

import SwiftUI

struct WorkspaceSidebarContainer: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Binding var isFileImporterPresented: Bool

    var onHistory: (() -> Void)? = nil

    var isIPhone: Bool {
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom == .phone
        #else
            false
        #endif
    }

    var body: some View {
        Group {
            if !viewModel.documents.isEmpty {
                WorkspaceSidebarView(viewModel: viewModel, onHistory: onHistory)
            } else {
                SignumEmptyStateView(
                    title: "Mesa Vacía",
                    systemImage: "doc.viewfinder",
                    description: "Agrega documentos a la mesa para comenzar a analizar. Puedes arrastrarlos aquí o seleccionar archivos para comenzar.",
                    actionLabel: isIPhone
                        ? "Seleccionar" : nil,
                    action: isIPhone
                        ? { isFileImporterPresented = true } : nil
                )
            }
        }
    }
}

#Preview("Mesa Vacía") {
    let vm = WorkspaceViewModel()
    vm.documents = []
    return WorkspaceSidebarContainer(
        viewModel: vm,
        isFileImporterPresented: .constant(false)
    )
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
    vm.documents = [.mock]
    vm.selectedDocumentID = vm.documents.first?.id

    return WorkspaceSidebarContainer(
        viewModel: vm,
        isFileImporterPresented: .constant(false)
    )
}

#Preview("Procesando") {
    let vm = WorkspaceViewModel()
    var doc = LegalDocument.mock
    doc.status = .analyzing
    vm.documents = [doc]
    vm.isProcessing = true
    vm.totalProgress = 0.5

    return WorkspaceSidebarContainer(
        viewModel: vm,
        isFileImporterPresented: .constant(false)
    )
}
