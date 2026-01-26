//
//  egalDocument+Mock.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation

extension LegalDocument {
    /// Genera un documento de prueba usando un archivo del Bundle.
    static var mock: LegalDocument {
        let url =
            Bundle.main.url(
                forResource: "Lorem_Ipsum",
                withExtension: "pdf",
            ) ?? URL(fileURLWithPath: "/dev/null")

        var doc = LegalDocument(url: url)
        doc.docType = "JUICIO DE AMPARO"
        doc.expediente = "973/2026"
        doc.status = .needsReview
        doc.suggestedName = "MX 0942 dsahbdud 12982end.pdf"
        doc.userEditedName = doc.suggestedName ?? doc.originalFileName

        return doc
    }
}
