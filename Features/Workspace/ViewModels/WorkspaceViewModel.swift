//
//  WorkspaceViewModel.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class WorkspaceViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var documents: [LegalDocument] = []
    @Published var selectedDocumentID: UUID?

    // Estados de proceso (IA)
    @Published var isProcessing: Bool = false
    @Published var totalProgress: Double = 0.0

    // Estados de Importación (UI Feedback)
    @Published var isImporting: Bool = false
    @Published var importErrorMessage: String?

    // MARK: - Dependencies & Private Storage
    private let importService: FileImporting
    private var securityAccessURLs: Set<URL> = []

    // MARK: - Computed Properties
    var selectedDocument: LegalDocument? {
        documents.first { $0.id == selectedDocumentID }
    }

    // MARK: - Initialization
    /// Inicializador con inyección de dependencias.
    /// Usamos 'nil' por defecto para evitar warnings de aislamiento de actores en el parámetro.
    init(importService: FileImporting? = nil) {
        // Si no se inyecta nada (producción), usamos el singleton compartido.
        self.importService = importService ?? FileImportService.shared
    }

    // MARK: - File Management

    /// Agrega archivos al espacio de trabajo de forma asíncrona.
    /// Maneja carpetas y archivos individuales sin bloquear la UI.
    func addFiles(from urls: [URL]) {
        guard !isImporting else { return }

        // 1. Activamos estado de carga (bloqueo de interacción o spinner)
        isImporting = true
        importErrorMessage = nil

        Task {
            // 2. Delegamos el trabajo pesado al servicio (Background Actor)
            let result = await importService.processImport(from: urls)

            // 3. Volvemos al MainActor para actualizar la UI
            handleImportResults(result)

            // 4. Finalizamos estado de carga con una pequeña animación/delay si es necesario
            try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2s para suavidad visual
            isImporting = false
        }
    }

    /// Procesa los resultados del servicio y actualiza el estado local.
    private func handleImportResults(
        _ results: (successes: [ImportResult], failures: [URL: FileImportError])
    ) {
        var newDocumentsCount = 0

        for item in results.successes {
            // A. Persistencia de Permisos (Security Scope)
            // El ViewModel es dueño de la sesión de trabajo, así que solicitamos acceso persistente.
            if item.url.startAccessingSecurityScopedResource() {
                securityAccessURLs.insert(item.url)
            }

            // B. Evitar duplicados
            if !documents.contains(where: { $0.originalURL == item.url }) {
                let newDoc = LegalDocument(url: item.url)
                documents.append(newDoc)
                newDocumentsCount += 1
            }
        }

        // C. Selección automática (UX)
        // Si no había nada seleccionado y agregamos algo, seleccionamos el primero disponible.
        if selectedDocumentID == nil, let first = documents.first {
            selectedDocumentID = first.id
        }

        // 3. Gestión de Errores
        if !results.failures.isEmpty {
            // Construimos un mensaje útil para el usuario/estado
            let failureCount = results.failures.count
            // Tomamos el primer error como ejemplo para el mensaje
            let firstErrorDescription =
                results.failures.values.first?.localizedDescription
                ?? "Error desconocido"

            if failureCount == 1 {
                importErrorMessage =
                    "No se pudo importar un archivo: \(firstErrorDescription)"
            } else {
                importErrorMessage =
                    "Se importaron \(newDocumentsCount) archivos, pero \(failureCount) fallaron. Ejemplo: \(firstErrorDescription)"
            }

            // Imprimimos en consola para debug
            print("⚠️ Reporte de Importación: \(importErrorMessage ?? "")")
        } else if newDocumentsCount > 0 {
            // Si todo salió bien, limpiamos cualquier error previo
            importErrorMessage = nil
            print("✅ Importación exitosa de \(newDocumentsCount) archivos.")
        }

        print(
            "✅ Importación finalizada. \(newDocumentsCount) documentos nuevos añadidos."
        )
    }

    func removeDocument(_ document: LegalDocument) {
        documents.removeAll { $0.id == document.id }

        // Limpiamos referencias al documento seleccionado si lo borramos
        if selectedDocumentID == document.id {
            selectedDocumentID = nil
        }

        // Liberamos el recurso de seguridad
        if let accessURL = securityAccessURLs.remove(document.originalURL) {
            accessURL.stopAccessingSecurityScopedResource()
        }
    }

    // MARK: - Business Logic (Processing & Verification)

    /// Inicia el proceso de análisis por lotes (IA Pipeline).
    func startBatchProcessing() async {
        guard !documents.isEmpty else { return }

        isProcessing = true
        totalProgress = 0.0

        for index in documents.indices {
            guard
                documents[index].status == .pending
                    || documents[index].status == .error
            else {
                continue
            }

            documents[index].status = .analyzing

            // --- Simulación del Pipeline ---
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            documents[index].docType = "DOC DE PRUEBA"
            documents[index].expediente = "123/2024"
            documents[index].status = .needsReview

            totalProgress = Double(index + 1) / Double(documents.count)
        }

        isProcessing = false
    }

    /// Actualiza el nombre editado por el usuario y marca como verificado.
    func verifyDocument(id: UUID, newName: String) {
        if let index = documents.firstIndex(where: { $0.id == id }) {
            documents[index].userEditedName = newName
            documents[index].status = .verified
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
        // Liberar todos los permisos antes de limpiar
        for url in securityAccessURLs {
            url.stopAccessingSecurityScopedResource()
        }
        securityAccessURLs.removeAll()

        documents.removeAll()
        selectedDocumentID = nil
        totalProgress = 0.0
    }

    // MARK: - Deinit
    deinit {
        for url in securityAccessURLs {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
