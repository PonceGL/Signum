//
//  Input+Style.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 02/02/26.
//

import SwiftUI

struct SignumInputStyle: ViewModifier {
    var icon: String? = nil

    func body(content: Content) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .font(.body)
            }

            content
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.7), lineWidth: 1)
        )
    }
}

extension View {
    func signumInput(icon: String? = nil) -> some View {
        self.modifier(SignumInputStyle(icon: icon))
    }
}
