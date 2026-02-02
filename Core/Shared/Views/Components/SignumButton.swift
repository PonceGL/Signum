//
//  SignumButton.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 02/02/26.
//

import SwiftUI

struct SignumButton: View {

    let title: String
    var iconLeft: String? = nil
    var iconRight: String? = nil
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var isDisabled: Bool = false

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let iconLeft = iconLeft {
                    Image(systemName: iconLeft)
                        .font(.body.weight(.semibold))
                }

                Text(title)
                    .fontWeight(.semibold)

                if let iconRight = iconRight {
                    Image(systemName: iconRight)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isDisabled ? Color.secondary.opacity(0.3) : backgroundColor
            )
            .foregroundStyle(isDisabled ? .secondary : foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(SignumButtonStyle())
        .disabled(isDisabled)
    }
}

struct SignumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 1. Solo texto (Clásico)
        SignumButton(title: "Confirmar") {
            print("Acción ejecutada")
        }

        // 2. Icono a la izquierda (Estilo 'Añadir')
        SignumButton(title: "Nuevo Documento", iconLeft: "plus.circle.fill") {
            // Lógica
        }

        // 3. Icono a la derecha (Estilo 'Siguiente')
        SignumButton(
            title: "Continuar",
            iconRight: "chevron.right",
            backgroundColor: .green
        ) {
            // Lógica
        }

        // 4. Ambos iconos (Estilo informativo)
        SignumButton(
            title: "Subir Archivo",
            iconLeft: "doc.badge.arrow.up",
            iconRight: "arrow.up"
        ) {
            // Lógica
        }
    }
}
