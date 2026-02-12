//
//  View+DragDrop.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 30/01/26.
//
//  ⚠️ NOTA: Este código de drag & drop ya NO se utiliza en la aplicación.
//  La funcionalidad de drag & drop fue deshabilitada porque no podemos garantizar
//  permisos de escritura confiables en ambas plataformas (macOS 13+ y iPadOS 16+).
//  La aplicación ahora solo permite importar carpetas mediante el file importer nativo.
//  Este archivo se mantiene por si en el futuro se necesita reactivar esta funcionalidad.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentDropModifier: ViewModifier {
    var viewModel: WorkspaceViewModel

    @State private var isTargeted: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if isTargeted {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor, lineWidth: 3)
                        .padding(2)
                        .ignoresSafeArea()
                }
            }
            .onDrop(of: [.pdf, .folder], isTargeted: $isTargeted) { providers in

                Task {
                    var urls: [URL] = []

                    for provider in providers {
                        if let url = await provider.loadSmartUrl() {
                            urls.append(url)
                        }
                    }

                    if !urls.isEmpty {
                        await MainActor.run {
                            viewModel.addFiles(from: urls)
                        }
                    }
                }

                return true
            }
    }
}

extension View {
    func withDocumentDropSupport(viewModel: WorkspaceViewModel) -> some View {
        self.modifier(DocumentDropModifier(viewModel: viewModel))
    }
}

// MARK: - NSItemProvider Helper (Estrategia Secuencial)
extension NSItemProvider {

    /// Intenta cargar la URL probando tipos específicos en orden de prioridad.
    fileprivate func loadSmartUrl() async -> URL? {
        // 1. Intento: Carpeta (Prioridad Alta)
        if let url = await getURL(for: .folder) {
            return url
        }

        // 2. Intento: URL de Archivo Genérica (Estándar en Mac)
        if let url = await getURL(for: .fileURL) {
            return url
        }

        // 3. Intento: PDF Específico (Común en iPad arrastrando desde Files)
        if let url = await getURL(for: .pdf) {
            return url
        }

        return nil
    }

    /// Helper genérico que intenta extraer una URL para un tipo de dato específico.
    /// Retorna nil si el provider no soporta el tipo o falla la carga.
    fileprivate func getURL(for type: UTType) async -> URL? {
        guard hasItemConformingToTypeIdentifier(type.identifier) else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            loadItem(forTypeIdentifier: type.identifier, options: nil) {
                (item, error) in
                // Opción A: Es directamente una URL
                if let url = item as? URL {
                    continuation.resume(returning: url)
                }
                // Opción B: Es Data que representa una URL (sucede a veces en drop complejos)
                else if let data = item as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                {
                    continuation.resume(returning: url)
                }
                // Opción C: Falló
                else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
