//
//  WorkspaceDetailContainer.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 26/01/26.
//

import SwiftUI

struct WorkspaceDetailContainer: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Binding var isFileImporterPresented: Bool

    var body: some View {
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
    }
}

#Preview("Mesa Vacía") {
    let vm = WorkspaceViewModel()
    vm.documents = []
    return WorkspaceDetailContainer(
        viewModel: vm,
        isFileImporterPresented: .constant(false)
    )
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
    vm.documents = [.mock]
    vm.selectedDocumentID = vm.documents.first?.id
    return WorkspaceDetailContainer(
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
    return WorkspaceDetailContainer(
        viewModel: vm,
        isFileImporterPresented: .constant(false)
    )
}
