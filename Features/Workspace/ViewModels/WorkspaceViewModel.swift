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

        // 1. Procesar Éxitos
        for item in results.successes {
            if !securityAccessURLs.contains(item.originalSource) {
                if item.originalSource.startAccessingSecurityScopedResource() {
                    securityAccessURLs.insert(item.originalSource)
                    print(
                        "🔐 Acceso seguro garantizado para: \(item.originalSource.lastPathComponent)"
                    )
                } else {
                    print(
                        "❌ Error al obtener acceso seguro para: \(item.originalSource.lastPathComponent)"
                    )
                }
            }

            // Evitar duplicados en la lista visual
            if !documents.contains(where: { $0.originalURL == item.url }) {
                let newDoc = LegalDocument(url: item.url)
                documents.append(newDoc)
                newDocumentsCount += 1
            }
        }

        // 2. Selección automática (Con Delay Táctico para UI)
        let shouldSelectFirst = (selectedDocumentID == nil)
        let firstDocID = documents.first?.id

        if shouldSelectFirst, let firstID = firstDocID {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 200_000_000)

                if documents.contains(where: { $0.id == firstID }) {
                    self.selectedDocumentID = firstID
                }
            }
        }

        // 3. Gestión de Errores
        if !results.failures.isEmpty {
            let failureCount = results.failures.count
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
            print("⚠️ Reporte de Importación: \(importErrorMessage ?? "")")
        } else if newDocumentsCount > 0 {
            importErrorMessage = nil
            print("✅ Importación exitosa de \(newDocumentsCount) archivos.")
        }
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
        // PASO 1: Deseleccionar primero.
        selectedDocumentID = nil

        // PASO 2: Liberar recursos de seguridad
        for url in securityAccessURLs {
            url.stopAccessingSecurityScopedResource()
        }
        securityAccessURLs.removeAll()

        // PASO 3: Ahora sí, destruir los datos
        documents.removeAll(keepingCapacity: false)

        // PASO 4: Resetear estados auxiliares
        totalProgress = 0.0
        importErrorMessage = nil
        isImporting = false
        isProcessing = false

        print("🧹 Workspace limpiado correctamente.")
    }

    // MARK: - Deinit
    deinit {
        for url in securityAccessURLs {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
