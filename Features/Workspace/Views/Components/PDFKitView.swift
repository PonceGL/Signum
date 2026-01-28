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
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.maxScaleFactor = 4.0
        pdfView.minScaleFactor = 0.5
        pdfView.backgroundColor = .clear
        return pdfView
    }

    private func updateBaseView(_ pdfView: PDFView) {
        if pdfView.document?.documentURL != document?.documentURL {
            pdfView.document = document
        }
    }
}
