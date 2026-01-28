//
//  PDFPreviewView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import PDFKit
import SwiftUI

struct PDFPreviewView: View {
    let document: LegalDocument

    // TODO: Implementar un Coordinador para controlar el nivel de zoom de forma programática

    // Cargamos el PDFDocument de forma perezosa
    private var pdfDocument: PDFDocument? {
        PDFDocument(url: document.originalURL)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if document.originalURL.path.contains("/dev/null") {
                Text("Error: No se encontró el PDF en el Bundle")
                    .foregroundColor(.red)
            }

            PDFKitView(document: pdfDocument).edgesIgnoringSafeArea(.all)

            // Controles de Zoom
            VStack {
                Button(action: { /* TODO: Lógica de Zoom + */  }) {
                    Image(systemName: "plus.magnifyingglass")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }

                Button(action: { /* TODO: Lógica de Zoom - */  }) {
                    Image(systemName: "minus.magnifyingglass")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding()
            .buttonStyle(.plain)
        }
    }
}

#Preview("Visor con Documento") {
    PDFPreviewView(document: .mock)
}
