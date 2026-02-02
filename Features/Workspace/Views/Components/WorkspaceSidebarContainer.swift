//
//  WorkspaceSidebarContainer.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 26/01/26.
//

import SwiftUI

struct WorkspaceSidebarContainer: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var isFileImporterPresented: Bool
    
    var onHistory: (() -> Void)? = nil

    var body: some View {
        Group {
            if !viewModel.documents.isEmpty {
                WorkspaceSidebarView(viewModel: viewModel, onHistory: onHistory)
            } else {
                SignumEmptyStateView(
                    title: "Mesa Vacía",
                    systemImage: "doc.viewfinder",
                    description: "Arrastra archivos para comenzar.",
                    actionLabel: horizontalSizeClass == .compact ? "Seleccionar Archivos" : nil,
                    action: horizontalSizeClass == .compact ? { isFileImporterPresented = true } : nil
                )
            }
        }
    }
}

#Preview("Mesa Vacía") {
    let vm = WorkspaceViewModel()
    vm.documents = []
    return WorkspaceSidebarContainer(viewModel: vm, isFileImporterPresented: .constant(false))
}

#Preview("Con Archivo Seleccionado") {
    let vm = WorkspaceViewModel()
    vm.documents = [.mock]
    vm.selectedDocumentID = vm.documents.first?.id

    return WorkspaceSidebarContainer(viewModel: vm, isFileImporterPresented: .constant(false))
}

#Preview("Procesando") {
    let vm = WorkspaceViewModel()
    var doc = LegalDocument.mock
    doc.status = .analyzing
    vm.documents = [doc]
    vm.isProcessing = true
    vm.totalProgress = 0.5

    return WorkspaceSidebarContainer(viewModel: vm, isFileImporterPresented: .constant(false))
}
