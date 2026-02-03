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

//// Tal vez funcioné, hay que hacer pruebas de usabilidad con el inspector
//struct FloatingActionCard: View {
//    @State private var fileName: String = ""
//    var onConfirm: (String) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Nombre Sugerido / Final")
//                .font(.caption)
//                .fontWeight(.bold)
//            
//            SignumTextField(
//                title: "Nombre del archivo",
//                text: $fileName,
//            )
//
//            Spacer()
//                .frame(height: 10)
//            
//            SignumButton(title: "Confirmar") {
//                onConfirm(fileName)
//            }
//        }
//        .padding(20)
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
//                .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
//        .frame(maxWidth: 380)
//    }
//}

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
