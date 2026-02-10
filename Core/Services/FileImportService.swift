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
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing { url.stopAccessingSecurityScopedResource() }
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
                let folderResults = await processDirectory(url)
                if folderResults.isEmpty {
                    failures[url] = .isDirectoryButEmpty
                } else {
                    successes.append(contentsOf: folderResults)
                }
            } else {
                // LOGICA DE ARCHIVO INDIVIDUAL
                if let type = resourceValues.contentType,
                    type.conforms(to: .pdf)
                {
                    successes.append(
                        ImportResult(url: url, originalSource: url)
                    )
                } else {
                    failures[url] = .invalidFileType
                }
            }
        }

        return (successes, failures)
    }

    private func processDirectory(_ folderURL: URL) async -> [ImportResult] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.contentTypeKey]

        guard
            let files = try? fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            )
        else {
            return []
        }

        var validPDFs: [ImportResult] = []

        for fileURL in files {
            if let values = try? fileURL.resourceValues(forKeys: [
                .contentTypeKey
            ]),
                let type = values.contentType,
                type.conforms(to: .pdf)
            {
                validPDFs.append(
                    ImportResult(url: fileURL, originalSource: folderURL)
                )
            }
        }

        return validPDFs
    }
}
