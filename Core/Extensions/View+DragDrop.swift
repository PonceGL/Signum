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
            .dropDestination(for: URL.self) { items, location in
                viewModel.addFiles(from: items)
                return true
            } isTargeted: { targeted in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isTargeted = targeted
                }
            }
    }
}

extension View {
    func withDocumentDropSupport(viewModel: WorkspaceViewModel) -> some View {
        self.modifier(DocumentDropModifier(viewModel: viewModel))
    }
}
