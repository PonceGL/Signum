//
//  LegalDocument.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation
import UniformTypeIdentifiers

enum InvalidReason: String, Codable, Equatable {
    case emptyFile      // 0 bytes
    case corrupted      // No se puede leer como PDF válido
    case readPermission // Sin permisos de lectura
    
    var localizedDescription: String {
        switch self {
        case .emptyFile:
            return "Archivo vacío (0 bytes)"
        case .corrupted:
            return "Archivo corrupto o dañado"
        case .readPermission:
            return "Sin permisos de lectura"
        }
    }
}

enum DocumentStatus: Equatable, Codable {
    case pending        // Recién agregado
    case analyzing      // En el pipeline OCR/ML
    case needsReview    // IA terminó, espera al humano
    case verified       // Humano confirmó
    case renamed        // Acción física en disco completada
    case error(String)  // Fallo en lectura o permisos
    case invalid(reason: InvalidReason)  // Archivo no válido
    
    // Codable conformance manual para associated values
    enum CodingKeys: String, CodingKey {
        case type, errorMessage, invalidReason
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "pending": self = .pending
        case "analyzing": self = .analyzing
        case "needsReview": self = .needsReview
        case "verified": self = .verified
        case "renamed": self = .renamed
        case "error":
            let message = try container.decode(String.self, forKey: .errorMessage)
            self = .error(message)
        case "invalid":
            let reason = try container.decode(InvalidReason.self, forKey: .invalidReason)
            self = .invalid(reason: reason)
        default:
            self = .pending
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .pending:
            try container.encode("pending", forKey: .type)
        case .analyzing:
            try container.encode("analyzing", forKey: .type)
        case .needsReview:
            try container.encode("needsReview", forKey: .type)
        case .verified:
            try container.encode("verified", forKey: .type)
        case .renamed:
            try container.encode("renamed", forKey: .type)
        case .error(let message):
            try container.encode("error", forKey: .type)
            try container.encode(message, forKey: .errorMessage)
        case .invalid(let reason):
            try container.encode("invalid", forKey: .type)
            try container.encode(reason, forKey: .invalidReason)
        }
    }
}

/// Entidad principal que representa un archivo PDF y sus metadatos legales.
struct LegalDocument: Identifiable, Hashable {
    let id: UUID

    // --- Datos de Archivo ---
    var originalURL: URL
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
