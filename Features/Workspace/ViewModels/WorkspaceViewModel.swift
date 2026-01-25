//
//  WorkspaceViewModel.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation
import SwiftUI
import Combine
import UniformTypeIdentifiers

@MainActor
class WorkspaceViewModel: ObservableObject {
    // --- Estado de la UI ---
    @Published var documents: [LegalDocument] = []
    @Published var selectedDocumentID: UUID?
    @Published var isProcessing: Bool = false
    @Published var totalProgress: Double = 0.0

    // Propiedad computada para obtener el documento seleccionado
    var selectedDocument: LegalDocument? {
        documents.first { $0.id == selectedDocumentID }
    }

    /// Agrega archivos al espacio de trabajo validando el tipo y los permisos.
    /// - Parameter urls: Arreglo de URLs provenientes del selector o Drag & Drop.
    func addFiles(from urls: [URL]) {
        for url in urls {
            // 1. Validar que sea PDF
            guard url.pathExtension.lowercased() == "pdf" else { continue }

            // 2. Manejo de Seguridad (iPad/Mac)
            // Es obligatorio para archivos fuera del Sandbox
            let canAccess = url.startAccessingSecurityScopedResource()

            // Creamos el modelo (esto inicializa el estado como .pending)
            let newDoc = LegalDocument(url: url)

            // Evitar duplicados por ruta
            if !documents.contains(where: { $0.originalURL == url }) {
                documents.append(newDoc)
            }

            // Si es el primer archivo, lo seleccionamos automáticamente
            if documents.count == 1 {
                selectedDocumentID = newDoc.id
            }

            // Nota: En una implementación de persistencia real,
            // deberíamos mantener el acceso hasta que se cierre la app.
            if canAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
    }

    /// Inicia el proceso de análisis por lotes (IA Pipeline).
    func startBatchProcessing() async {
        guard !documents.isEmpty else { return }

        isProcessing = true
        totalProgress = 0.0

        for index in documents.indices {
            // Solo procesamos los que están pendientes o con error
            guard
                documents[index].status == .pending
                    || documents[index].status == .error
            else {
                continue
            }

            documents[index].status = .analyzing

            // --- Simulación del Pipeline (OCR + TinyML) ---
            // Aquí irá la llamada al motor nativo en el siguiente paso
            try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 seg de delay

            // Actualizamos con datos de prueba
            documents[index].docType = "JUICIO DE AMPARO"
            documents[index].expediente = "123/2024"
            documents[index].status = .needsReview

            // Actualizar progreso global
            totalProgress = Double(index + 1) / Double(documents.count)
        }

        isProcessing = false
    }

    /// Actualiza el nombre editado por el usuario y marca como verificado.
    func verifyDocument(id: UUID, newName: String) {
        if let index = documents.firstIndex(where: { $0.id == id }) {
            documents[index].userEditedName = newName
            documents[index].status = .verified

            // Lógica de "Cascada": Saltar al siguiente pendiente
            selectNextPendingDocument()
        }
    }

    private func selectNextPendingDocument() {
        if let next = documents.first(where: {
            $0.status == .needsReview || $0.status == .pending
        }) {
            selectedDocumentID = next.id
        }
    }

    func clearWorkspace() {
        documents.removeAll()
        selectedDocumentID = nil
        totalProgress = 0.0
    }
}
