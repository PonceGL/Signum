//
//  SubfolderPickerView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 09/02/26.
//

import SwiftUI

struct SubfolderPickerView: View {
    let parentFolderName: String
    let subfolders: [URL]
    let onSelect: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(subfolders, id: \.self) { folder in
                        Button(action: {
                            onSelect(folder)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(folder.lastPathComponent)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(folder.path)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Subcarpetas disponibles en '\(parentFolderName)'")
                }
            }
            #if os(macOS)
            .listStyle(.inset)
            #endif
            .navigationTitle("Seleccionar Carpeta")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 400)
        #endif
    }
}

#Preview {
    SubfolderPickerView(
        parentFolderName: "Documentos 2024",
        subfolders: [
            URL(fileURLWithPath: "/Users/test/Documents/Enero"),
            URL(fileURLWithPath: "/Users/test/Documents/Febrero"),
            URL(fileURLWithPath: "/Users/test/Documents/Marzo")
        ],
        onSelect: { url in
            print("Selected: \(url.lastPathComponent)")
        }
    )
}
