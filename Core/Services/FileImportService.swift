//
//  FileImportService.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 30/01/26.
//

import Foundation
import UniformTypeIdentifiers

enum FileImportError: LocalizedError {
    case permissionDenied
    case invalidFileType
    case unreadable
    case isDirectoryButEmpty
    case directoryHasNoValidPDFs(hasSubfolders: Bool, subfolders: [URL])
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied: 
            return "Sin permisos de lectura."
        case .invalidFileType: 
            return "No es un archivo PDF válido."
        case .unreadable: 
            return "No se pudo leer el archivo."
        case .isDirectoryButEmpty: 
            return "Carpeta sin PDFs válidos."
        case .directoryHasNoValidPDFs(let hasSubfolders, _):
            if hasSubfolders {
                return "No hay PDFs en el nivel principal. La carpeta contiene subcarpetas."
            } else {
                return "La carpeta contiene archivos pero ninguno es PDF."
            }
        case .unknown: 
            return "Error desconocido."
        }
    }
}

struct ImportResult: Identifiable {
    let id = UUID()
    let url: URL
    let originalSource: URL
    let isValid: Bool
    let invalidReason: InvalidReason?
    
    init(url: URL, originalSource: URL, isValid: Bool = true, invalidReason: InvalidReason? = nil) {
        self.url = url
        self.originalSource = originalSource
        self.isValid = isValid
        self.invalidReason = invalidReason
    }
}

protocol FileImporting {
    func processImport(from urls: [URL]) async -> (
        successes: [ImportResult], failures: [URL: FileImportError]
    )
}

actor FileImportService: FileImporting {

    static let shared = FileImportService()

    func processImport(from urls: [URL]) async -> (
        successes: [ImportResult], failures: [URL: FileImportError]
    ) {
        var successes: [ImportResult] = []
        var failures: [URL: FileImportError] = [:]

        for url in urls {
            // 1. Gestionar Seguridad (Start Access)
            // IMPORTANTE: NO liberamos el recurso aquí con defer porque el ViewModel
            // necesita mantener los permisos activos para poder renombrar archivos.
            // El ViewModel será responsable de liberar los permisos cuando sea necesario.
            let accessing = url.startAccessingSecurityScopedResource()
            
            if !accessing {
                print("⚠️ No se pudo obtener acceso de seguridad para: \(url.lastPathComponent)")
            } else {
                print("✅ Acceso de seguridad concedido para: \(url.lastPathComponent)")
            }

            // 2. Verificar si es Directorio o Archivo
            guard
                let resourceValues = try? url.resourceValues(forKeys: [
                    .isDirectoryKey, .contentTypeKey,
                ]),
                let isDirectory = resourceValues.isDirectory
            else {
                failures[url] = .unreadable
                continue
            }

            if isDirectory {
                // LOGICA DE CARPETAS (Nivel 1)
                let folderAnalysis = await analyzeDirectory(url)
                
                // Separar PDFs válidos de zombies
                let validPDFs = folderAnalysis.validPDFs.filter { $0.isValid }
                let zombiePDFs = folderAnalysis.validPDFs.filter { !$0.isValid }
                
                if validPDFs.isEmpty && zombiePDFs.isEmpty {
                    // No hay PDFs en absoluto (ni válidos ni zombies)
                    if folderAnalysis.totalItems == 0 {
                        // Caso A: Carpeta completamente vacía
                        failures[url] = .isDirectoryButEmpty
                    } else if folderAnalysis.hasSubfolders {
                        // Caso C: Carpeta profunda (tiene subcarpetas pero no PDFs en nivel 1)
                        failures[url] = .directoryHasNoValidPDFs(
                            hasSubfolders: true,
                            subfolders: folderAnalysis.subfolders
                        )
                    } else {
                        // Caso B: Carpeta con ruido (archivos pero no PDFs)
                        failures[url] = .directoryHasNoValidPDFs(
                            hasSubfolders: false,
                            subfolders: []
                        )
                    }
                } else {
                    // Hay PDFs (válidos o zombies), agregarlos todos
                    successes.append(contentsOf: folderAnalysis.validPDFs)
                }
            } else {
                // LOGICA DE ARCHIVO INDIVIDUAL
                if let type = resourceValues.contentType,
                    type.conforms(to: .pdf)
                {
                    // Validar que el archivo no sea zombie (0 bytes)
                    if let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
                       fileSize > 0 {
                        successes.append(
                            ImportResult(url: url, originalSource: url, isValid: true)
                        )
                    } else {
                        // Caso D: Archivo zombie (0 bytes) - agregarlo como inválido para mostrarlo en la UI
                        successes.append(
                            ImportResult(url: url, originalSource: url, isValid: false, invalidReason: .emptyFile)
                        )
                        print("⚠️ Archivo zombie individual detectado: \(url.lastPathComponent)")
                    }
                } else {
                    failures[url] = .invalidFileType
                }
            }
        }

        return (successes, failures)
    }

    /// Estructura para retornar análisis completo de un directorio
    private struct DirectoryAnalysis {
        let validPDFs: [ImportResult]
        let totalItems: Int
        let hasSubfolders: Bool
        let subfolders: [URL]
    }
    
    /// Analiza un directorio y retorna información detallada sobre su contenido
    private func analyzeDirectory(_ folderURL: URL) async -> DirectoryAnalysis {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.contentTypeKey, .isDirectoryKey, .fileSizeKey]
        
        // IMPORTANTE: Los permisos ya fueron solicitados en processImport()
        // No necesitamos volver a solicitarlos ni liberarlos aquí
        
        guard
            let items = try? fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            )
        else {
            print("❌ No se pudo leer el contenido de: \(folderURL.lastPathComponent)")
            print("   Path: \(folderURL.path)")
            return DirectoryAnalysis(
                validPDFs: [],
                totalItems: 0,
                hasSubfolders: false,
                subfolders: []
            )
        }
        
        print("📂 Analizando carpeta: \(folderURL.lastPathComponent) - \(items.count) items encontrados")

        var validPDFs: [ImportResult] = []
        var subfolders: [URL] = []
        
        for itemURL in items {
            guard let values = try? itemURL.resourceValues(forKeys: Set(keys)) else {
                continue
            }
            
            // Detectar subcarpetas
            if let isDirectory = values.isDirectory, isDirectory {
                subfolders.append(itemURL)
                continue
            }
            
            // Validar PDFs
            if let type = values.contentType,
               type.conforms(to: .pdf) {
                // Caso D: Validar que no sea zombie (0 bytes)
                if let fileSize = values.fileSize, fileSize > 0 {
                    validPDFs.append(
                        ImportResult(url: itemURL, originalSource: folderURL, isValid: true)
                    )
                } else {
                    // Archivo zombie (0 bytes) - agregarlo como inválido para mostrarlo en la UI
                    validPDFs.append(
                        ImportResult(url: itemURL, originalSource: folderURL, isValid: false, invalidReason: .emptyFile)
                    )
                    print("⚠️ Archivo zombie detectado: \(itemURL.lastPathComponent)")
                }
            }
        }

        let result = DirectoryAnalysis(
            validPDFs: validPDFs,
            totalItems: items.count,
            hasSubfolders: !subfolders.isEmpty,
            subfolders: subfolders
        )
        
        print("✅ Análisis completo: \(validPDFs.count) PDFs válidos, \(subfolders.count) subcarpetas")
        
        return result
    }
}
