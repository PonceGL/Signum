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

    private var pdfDocument: PDFDocument? {
        PDFDocument(url: document.originalURL)
    }

    var body: some View {
        if document.originalURL.path.contains("/dev/null") {
            Text("Error: No se encontró el PDF en el Bundle")
                .foregroundColor(.red)
        }

        PDFKitView(document: pdfDocument)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Visor con Documento") {
    PDFPreviewView(document: .mock)
}
