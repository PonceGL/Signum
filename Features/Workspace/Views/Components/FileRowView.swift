//
//  FileRowView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

struct FileRowView: View {
    let document: LegalDocument
    let isSelected: Bool
    
    private var isInvalid: Bool {
        if case .invalid = document.status {
            return true
        }
        return false
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isInvalid ? "doc.badge.exclamationmark" : "doc.plaintext.fill")
                .font(.title2)
                .foregroundColor(isInvalid ? .secondary : (isSelected ? .white : .accentColor))

            VStack(alignment: .leading, spacing: 4) {
                Text(document.originalFileName)
                    .font(.headline)
                    .lineLimit(1)
                    .strikethrough(isInvalid, color: .secondary)

                if let type = document.docType {
                    Text(type)
                        .font(.caption)
                        .foregroundColor(
                            isSelected ? .white.opacity(0.8) : .secondary
                        )
                }
                
                if isInvalid, case .invalid(let reason) = document.status {
                    Text(reasonText(for: reason))
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.8))
                }
            }

            Spacer()

            StatusBadge(status: document.status)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .opacity(isInvalid ? 0.5 : 1.0)
        .allowsHitTesting(!isInvalid)
    }
    
    private func reasonText(for reason: InvalidReason) -> String {
        switch reason {
        case .emptyFile:
            return "Archivo vacío"
        case .corrupted:
            return "Archivo dañado"
        case .readPermission:
            return "Sin permisos de lectura"
        }
    }
}

#Preview("Fila de Archivo") {
    VStack(spacing: 8) {
        FileRowView(
            document: LegalDocument(
                url: URL(fileURLWithPath: "Amparo_973_2024.pdf")
            ),
            isSelected: false
        )
        FileRowView(
            document: LegalDocument(
                url: URL(fileURLWithPath: "Incidente_Suspension.pdf")
            ),
            isSelected: true
        )
        
        // Archivo zombie (vacío)
        FileRowView(
            document: {
                var doc = LegalDocument(url: URL(fileURLWithPath: "Documento_Vacio.pdf"))
                doc.status = .invalid(reason: .emptyFile)
                return doc
            }(),
            isSelected: false
        )
        
        // Archivo corrupto
        FileRowView(
            document: {
                var doc = LegalDocument(url: URL(fileURLWithPath: "Archivo_Danado.pdf"))
                doc.status = .invalid(reason: .corrupted)
                return doc
            }(),
            isSelected: false
        )
    }
    .padding()
    .frame(width: 300)
}
