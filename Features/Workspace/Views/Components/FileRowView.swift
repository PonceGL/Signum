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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.plaintext.fill")
                .font(.title2)
                .foregroundColor(isSelected ? .white : .accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.originalFileName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .white : .primary)

                if let type = document.docType {
                    Text(type)
                        .font(.caption)
                        .foregroundColor(
                            isSelected ? .white.opacity(0.8) : .secondary
                        )
                }
            }

            Spacer()

            StatusBadge(status: document.status)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
    }
}

#Preview("Fila de Archivo") {
    VStack {
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
    }
    .padding()
    .frame(width: 300)
}
