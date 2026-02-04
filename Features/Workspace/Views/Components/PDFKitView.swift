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
        func makeNSView(context: Context) -> PDFView { setupView() }
        func updateNSView(_ nsView: PDFView, context: Context) {
            updateBaseView(nsView)
        }
    #else
        func makeUIView(context: Context) -> PDFView { setupView() }
        func updateUIView(_ uiView: PDFView, context: Context) {
            updateBaseView(uiView)
        }
    #endif

    private func setupView() -> PDFView {
        let pdfView = PDFView()
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displaysAsBook = false
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = 0.1

        #if os(macOS)
            pdfView.backgroundColor = .controlBackgroundColor
        #else
            pdfView.backgroundColor = .systemBackground
        #endif

        return pdfView
    }

    private func updateBaseView(_ pdfView: PDFView) {
        guard let document = document,
            pdfView.document?.documentURL != document.documentURL
        else { return }

        pdfView.document = document

        DispatchQueue.main.async {
            withAnimation(
                .spring(response: 0.5, dampingFraction: 0.8)
            ) {
                // 1. Activamos el escalado automático
                pdfView.autoScales = true

                // 2. Forzamos el ajuste inicial al ancho disponible (SizeToFit)
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit

                // 3. Establecemos el factor de escala inicial como el mínimo permitido
                // para que el usuario no pueda "encoger" el PDF más allá del ancho de pantalla.
                pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
            }
        }
    }
}
