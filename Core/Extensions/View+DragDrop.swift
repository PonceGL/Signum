//
//  View+DragDrop.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 30/01/26.
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
                        if let url = await provider.loadUrl() {
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

extension NSItemProvider {
    fileprivate func loadUrl() async -> URL? {
        return await withCheckedContinuation { continuation in
            if hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                loadItem(
                    forTypeIdentifier: UTType.fileURL.identifier,
                    options: nil
                ) { (item, error) in
                    if let data = item as? Data,
                        let url = URL(dataRepresentation: data, relativeTo: nil)
                    {
                        continuation.resume(returning: url)
                    } else if let url = item as? URL {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }

            else if hasItemConformingToTypeIdentifier(UTType.folder.identifier)
            {
                loadItem(
                    forTypeIdentifier: UTType.folder.identifier,
                    options: nil
                ) { (item, error) in
                    if let url = item as? URL {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
