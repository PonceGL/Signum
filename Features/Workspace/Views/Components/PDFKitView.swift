//
//  PDFKitView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import PDFKit
import SwiftUI

#if os(macOS)
    typealias ViewRepresentable = NSViewRepresentable
#else
    typealias ViewRepresentable = UIViewRepresentable
#endif

struct PDFKitView: ViewRepresentable {
    let document: PDFDocument?

    #if os(macOS)
        func makeNSView(context: Context) -> PDFView {
            setupView()
        }

        func updateNSView(_ nsView: PDFView, context: Context) {
            nsView.document = document
        }
    #else
        func makeUIView(context: Context) -> PDFView {
            setupView()
        }

        func updateUIView(_ uiView: PDFView, context: Context) {
            uiView.document = document
        }
    #endif

    private func setupView() -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        // Permitir zoom con gestos/mouse
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = 0.5
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        if nsView.document?.documentURL != document?.documentURL {
            nsView.document = document
            // TODO: Implementar lógica para preservar el nivel de zoom al cambiar de archivo
        }
    }
}
