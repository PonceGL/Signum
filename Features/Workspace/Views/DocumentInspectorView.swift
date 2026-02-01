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

                TextField("Nombre del archivo", text: $editedName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, design: .monospaced))  // Monospaced para facilitar lectura de expedientes
                    #if os(iOS)
                        .textInputAutocapitalization(.characters)
                    #endif
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

            Button(action: {
                viewModel.finalizeAndRenameDocument(id: document.id, newName: editedName)
            }) {
                HStack {
                    Spacer()
                    Text("Confirmar")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])
        }
        .padding()
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
