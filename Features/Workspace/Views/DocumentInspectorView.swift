//
//  DocumentInspectorView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

struct DocumentInspectorView: View {
    let document: LegalDocument
    @ObservedObject var viewModel: WorkspaceViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var showInPhone: Bool {
        horizontalSizeClass == .compact && isIPhone
    }

    @State private var editedName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Renombrar Archivo")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre Sugerido / Final")
                    .font(.caption)
                    .fontWeight(.bold)
                
                SignumTextField(
                    title: "Nombre del archivo",
                    text: $editedName,
                )
            }

            Button(action: {
                editedName = document.originalFileName
            }) {
                Label("Restaurar original", systemImage: "arrow.uturn.backward")
                    .font(.caption)
            }
            .buttonStyle(.borderless)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Label(
                    document.docType ?? "Tipo no detectado",
                    systemImage: "doc.text.magnifyingglass"
                )
                Label(
                    document.expediente ?? "Expediente no detectado",
                    systemImage: "number.square"
                )
                Label(
                    document.oficioSeleccionado ?? "Oficio no detectado",
                    systemImage: "hand.point.up.left"
                )
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Spacer()
            
            SignumButton(title: "Confirmar") {
                viewModel.finalizeAndRenameDocument(id: document.id, newName: editedName)
            }
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])
        }
        .onAppear {
            editedName = document.userEditedName
        }
        .onSignumChange(of: document.id) { _, newValue in
            editedName = document.userEditedName
        }
    }
}

#Preview("Editando Amparo") {
    let doc = LegalDocument(url: URL(fileURLWithPath: "973_2024.pdf"))
    return DocumentInspectorView(document: doc, viewModel: WorkspaceViewModel())
        .frame(width: 300)
}
