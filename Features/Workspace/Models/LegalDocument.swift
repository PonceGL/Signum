//
//  LegalDocument.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation
import UniformTypeIdentifiers

enum DocumentStatus: String, Codable, CaseIterable {
    case pending  // Recién agregado
    case analyzing  // En el pipeline OCR/ML
    case needsReview  // IA terminó, espera al humano
    case verified  // Humano confirmó
    case renamed  // Acción física en disco completada
    case error  // Fallo en lectura o permisos
}

/// Entidad principal que representa un archivo PDF y sus metadatos legales.
struct LegalDocument: Identifiable, Hashable {
    let id: UUID

    // --- Datos de Archivo ---
    let originalURL: URL
    let originalFileName: String

    // --- Estado del Flujo ---
    var status: DocumentStatus
    var errorMessage: String?

    // --- Metadatos Extraídos (Sugerencias) ---
    var docType: String?  // Ej: "JUICIO DE AMPARO"
    var expediente: String?  // Ej: "973/2024"
    var oficioSeleccionado: String?  // El número con la marca física

    // --- Nombres para Renombrado ---
    var suggestedName: String?  // El nombre construido por el algoritmo
    var userEditedName: String  // El nombre que se muestra en el Input (inicializado con el original)

    // Flag de edición manual
    var isEditedManually: Bool = false

    // Implementación de Hashable para la navegación en SwiftUI
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LegalDocument, rhs: LegalDocument) -> Bool {
        lhs.id == rhs.id
    }
}

// Extension para inicialización rápida
extension LegalDocument {
    init(url: URL) {
        self.id = UUID()
        self.originalURL = url
        self.originalFileName = url.lastPathComponent
        self.userEditedName = url.lastPathComponent
        self.status = .pending
    }
}
