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

struct DuplicateAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let suggestedName: String?
    let confirmAction: (() -> Void)?
}

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
    @Published var importAlert: ImportAlert?
    @Published var duplicateAlert: DuplicateAlert?
    
    var useComplexDuplicateAlert: Bool = true
    
    // Navegación de subcarpetas
    @Published var showSubfolderPicker: Bool = false
    @Published var availableSubfolders: [URL] = []
    @Published var parentFolderName: String = ""
    @Published var shouldOpenFileImporter: Bool = false

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
    private func handleImportResults(_ results: (successes: [ImportResult], failures: [URL: FileImportError])) {
        // Si hay errores, procesarlos primero
        if !results.failures.isEmpty {
            handleImportErrors(results.failures)
        }
        
        // Si no hay éxitos y ya mostramos alerta, no continuar
        if results.successes.isEmpty {
            return
        }
        
        // Procesar éxitos normalmente
        processSuccessfulImports(results.successes)
    }
    
    /// Maneja los errores de importación mostrando alertas apropiadas
    private func handleImportErrors(_ failures: [URL: FileImportError]) {
        // Priorizar el primer error encontrado
        guard let (failedURL, error) = failures.first else { return }
        
        switch error {
        case .isDirectoryButEmpty:
            // Caso A: Carpeta vacía
            importAlert = .simple(
                title: "Carpeta vacía",
                message: "La carpeta '\(failedURL.lastPathComponent)' no contiene ningún archivo."
            )
            
        case .directoryHasNoValidPDFs(let hasSubfolders, let subfolders):
            if hasSubfolders {
                // Caso C: Carpeta profunda con subcarpetas
                importAlert = .folderWithSubfolders(
                    folderName: failedURL.lastPathComponent,
                    subfolders: subfolders,
                    onExplore: { [weak self] _ in
                        self?.showSubfolderPicker(subfolders)
                    }
                )
            } else {
                // Caso B: Carpeta con ruido (archivos no-PDF)
                importAlert = .simple(
                    title: "Sin archivos PDF",
                    message: "La carpeta '\(failedURL.lastPathComponent)' contiene archivos, pero ninguno es PDF."
                )
            }
            
        case .unreadable:
            // Caso D: Archivo zombie o corrupto
            importAlert = .simple(
                title: "Archivo no válido",
                message: "El archivo '\(failedURL.lastPathComponent)' está vacío o dañado."
            )
            
        case .invalidFileType:
            importAlert = .simple(
                title: "Tipo de archivo no soportado",
                message: "El archivo '\(failedURL.lastPathComponent)' no es un PDF válido."
            )
            
        case .permissionDenied:
            importAlert = .simple(
                title: "Sin permisos",
                message: "No se tienen permisos para leer '\(failedURL.lastPathComponent)'."
            )
            
        case .unknown:
            importAlert = .simple(
                title: "Error desconocido",
                message: "Ocurrió un error al importar '\(failedURL.lastPathComponent)'."
            )
        }
    }
    
    /// Procesa las importaciones exitosas
    private func processSuccessfulImports(_ successes: [ImportResult]) {
        var newDocumentsCount = 0
        
        // 1. Procesar Éxitos
        for item in successes {
                
                // ESTRATEGIA: Registrar la carpeta con permisos activos
                // Como ahora SOLO importamos carpetas (no archivos sueltos),
                // el FileImportService ya llamó startAccessingSecurityScopedResource() 
                // sobre la carpeta seleccionada (originalSource).
                // Necesitamos mantener estos permisos activos para poder renombrar los archivos.
                
                let folderWithPermissions = item.originalSource
                
                // Registrar la carpeta con permisos si no la tenemos ya
                if !securityAccessURLs.contains(folderWithPermissions) {
                    securityAccessURLs.insert(folderWithPermissions)
                    print("📝 Registrada carpeta con permisos activos: \(folderWithPermissions.lastPathComponent)")
                    print("   Path completo: \(folderWithPermissions.path)")
                }
                
                // Evitar duplicados en la lista visual
                if !documents.contains(where: { $0.originalURL == item.url }) {
                    var newDoc = LegalDocument(url: item.url)
                    
                    // Si el archivo es inválido (zombie), marcarlo con estado .invalid
                    if !item.isValid, let reason = item.invalidReason {
                        newDoc.status = .invalid(reason: reason)
                        print("🧟 Archivo zombie agregado: \(newDoc.originalFileName) - \(reason)")
                    }
                    
                    documents.append(newDoc)
                    newDocumentsCount += 1
                }
            }
            
            // 2. Selección automática (Con Delay para estabilidad de UI)
            let shouldSelectFirst = (selectedDocumentID == nil)
            let firstDocID = documents.first?.id
            
            if shouldSelectFirst, let firstID = firstDocID {
                Task { @MainActor in
                    // Delay táctico de 0.2s para esperar a las animaciones de la UI
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    
                    if documents.contains(where: { $0.id == firstID }) {
                        self.selectedDocumentID = firstID
                    }
                }
            }
            
        // 3. Mensaje de éxito
        if newDocumentsCount > 0 {
            importErrorMessage = nil
            print("✅ Importación exitosa de \(newDocumentsCount) archivos.")
        }
    }
    
    /// Muestra el selector de subcarpetas
    /// En macOS, debido a restricciones de sandbox, es mejor usar el file picker del sistema
    private func showSubfolderPicker(_ folders: [URL]) {
        guard !folders.isEmpty else { return }
        
        #if os(macOS)
        // En macOS, usar el file picker del sistema para obtener permisos de seguridad válidos
        print("📁 Abriendo file picker del sistema para seleccionar subcarpeta")
        shouldOpenFileImporter = true
        #else
        // En iOS/iPadOS, usar nuestro sheet personalizado (funciona bien)
        availableSubfolders = folders
        parentFolderName = folders.first?.deletingLastPathComponent().lastPathComponent ?? "Carpeta"
        showSubfolderPicker = true
        print("📁 Mostrando picker con \(folders.count) subcarpetas")
        #endif
    }
    
    /// Procesa la subcarpeta seleccionada por el usuario
    func selectSubfolder(_ folderURL: URL) {
        showSubfolderPicker = false
        
        print("📂 Usuario seleccionó: \(folderURL.lastPathComponent)")
        
        // CRÍTICO: Solicitar acceso de seguridad para la subcarpeta
        // Las subcarpetas NO heredan automáticamente el permiso de la carpeta padre
        let accessing = folderURL.startAccessingSecurityScopedResource()
        if accessing {
            print("� Acceso de seguridad concedido para: \(folderURL.lastPathComponent)")
        } else {
            print("⚠️ No se pudo obtener acceso de seguridad, intentando de todas formas...")
        }
        
        // Reiniciar el flujo de importación con la subcarpeta seleccionada
        addFiles(from: [folderURL])
        
        // Nota: No llamamos stopAccessingSecurityScopedResource aquí porque
        // el importService lo manejará en su propio scope
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
            // Procesar solo documentos pendientes o con error
            switch documents[index].status {
            case .pending, .error:
                break
            default:
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
    /// Renombra el archivo físico en disco y actualiza el modelo.
        /// - Parameters:
        ///   - id: ID del documento a procesar.
        ///   - newName: El nuevo nombre ingresado por el usuario (sin extensión).
        func finalizeAndRenameDocument(id: UUID, newName: String) {
            print("finalizeAndRenameDocument id: \(id), newName: \(newName)")
            guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
            
            let currentDoc = documents[index]
            let currentURL = currentDoc.originalURL // La URL actual completa
            
            // 1. Limpieza del nombre (Básico)
            var cleanName = newName
                if cleanName.lowercased().hasSuffix(".pdf") {
                    cleanName = String(cleanName.dropLast(4))
                }
            
            let safeName = cleanName.replacingOccurrences(of: "/", with: "-")
                                        .replacingOccurrences(of: ":", with: "-")
                                        .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 2. Construir la nueva ruta
            let folderURL = currentURL.deletingLastPathComponent()
            // Agregamos el nuevo nombre y aseguramos la extensión PDF
            let newURL = folderURL.appendingPathComponent(safeName).appendingPathExtension("pdf")
            
            // 3. CRÍTICO: Verificar y asegurar permisos de seguridad sobre la carpeta
            // Los permisos ya deberían estar activos desde processSuccessfulImports
            var hasPermissions = false
            
            // Buscar si tenemos permisos para esta carpeta o alguna carpeta padre
            for securedURL in securityAccessURLs {
                if folderURL == securedURL || folderURL.path.hasPrefix(securedURL.path) {
                    hasPermissions = true
                    print("✅ Permisos activos confirmados para: \(securedURL.lastPathComponent)")
                    print("   Renombrando archivo en: \(folderURL.lastPathComponent)")
                    break
                }
            }
            
            if !hasPermissions {
                print("❌ ERROR: No hay permisos activos para la carpeta: \(folderURL.lastPathComponent)")
                print("   URLs con permisos activos: \(securityAccessURLs.map { $0.lastPathComponent })")
                print("   Intentando obtener permisos de emergencia...")
                
                // Último intento: solicitar permisos directamente
                let emergencyAccess = folderURL.startAccessingSecurityScopedResource()
                if emergencyAccess {
                    print("✅ Permisos de emergencia concedidos")
                    securityAccessURLs.insert(folderURL)
                } else {
                    print("❌ No se pudieron obtener permisos de emergencia")
                    return
                }
            }
            
            // 4. Renombrado Físico (FileManager)
            // IMPORTANTE: Usamos moveItem que renombra el archivo IN-PLACE sin crear copias
            // Esto preserva la firma digital del archivo original
            do {
                // Checamos si es un cambio ÚNICAMENTE de mayúsculas/minúsculas en el mismo archivo
                let isCaseOnlyChange = (newURL.lastPathComponent.lowercased() == currentURL.lastPathComponent.lowercased()) && (newURL.path != currentURL.path)
                
                // Verificamos si ya existe un archivo con ese nombre y NO es sólo un cambio de case para el archivo actual
                if !isCaseOnlyChange && newURL.path != currentURL.path && FileManager.default.fileExists(atPath: newURL.path) {
                    print("⚠️ Error: Ya existe un archivo con el nombre '\(safeName)' en esta carpeta.")
                    
                    if useComplexDuplicateAlert {
                        var counter = 2
                        var incrementedName = ""
                        var incrementedURL = newURL
                        
                        while FileManager.default.fileExists(atPath: incrementedURL.path) {
                            incrementedName = "\(safeName) (\(counter))"
                            incrementedURL = folderURL.appendingPathComponent(incrementedName).appendingPathExtension("pdf")
                            counter += 1
                        }
                        
                        let finalName = incrementedName
                        self.duplicateAlert = DuplicateAlert(
                            title: "Archivo Existente",
                            message: "Ya existe un archivo con el nombre '\(safeName)' en esta carpeta. ¿Deseas guardarlo como '\(finalName)'?",
                            suggestedName: finalName,
                            confirmAction: { [weak self] in
                                Task { @MainActor in
                                    self?.finalizeAndRenameDocument(id: id, newName: finalName)
                                }
                            }
                        )
                    } else {
                        self.duplicateAlert = DuplicateAlert(
                            title: "Archivo Existente",
                            message: "Ya existe un archivo con el nombre '\(safeName)' en esta carpeta.",
                            suggestedName: nil,
                            confirmAction: nil
                        )
                    }
                    return
                }
                
                // Si es un cambio exclusivo de mayúsculas/minúsculas,
                // debemos hacer un rename en 2 pasos porque FileManager a veces ignora cambios que sólo afectan capitalización.
                if isCaseOnlyChange {
                    let tempURL = folderURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("pdf")
                    try FileManager.default.moveItem(at: currentURL, to: tempURL)
                    try FileManager.default.moveItem(at: tempURL, to: newURL)
                    print("🔄 Archivo renombrado in-place (Case-Preserving) a: \(newURL.lastPathComponent)")
                } else {
                    try FileManager.default.moveItem(at: currentURL, to: newURL)
                    print("✅ Archivo renombrado físicamente a: \(newURL.lastPathComponent)")
                }
                
                // 5. Actualizar el Modelo
                // Es crucial actualizar la URL en el modelo, si no, la próxima vez apuntará al archivo viejo.
                documents[index].userEditedName = safeName
                documents[index].originalURL = newURL
                documents[index].status = .verified
                
                // 6. Siguiente documento
                selectNextPendingDocument()
                
            } catch {
                print("❌ Error CRÍTICO al renombrar archivo: \(error.localizedDescription)")
                print("   Archivo origen: \(currentURL.path)")
                print("   Archivo destino: \(newURL.path)")
                print("   Carpeta padre: \(folderURL.path)")
                print("   Permisos en securityAccessURLs: \(securityAccessURLs.contains(folderURL))")
                // Aquí es donde sabremos si tenemos permisos de escritura reales.
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
