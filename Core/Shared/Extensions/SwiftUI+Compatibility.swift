//
//  SwiftUI+Compatibility.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 26/01/26.
//

import SwiftUI

// MARK: - View Compatibility Extensions
extension View {

    /// Un puente para el Inspector que usa la implementación nativa en v26 y una simulación de panel lateral en macOS 13.
    @ViewBuilder
    func signumInspector<InspectorContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> InspectorContent
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            // En versiones modernas (incluyendo la 26), usamos el nativo
            self.inspector(isPresented: isPresented, content: content)
        } else {
            // En macOS 13, lo simulamos usando un HStack en el contenedor
            self.modifier(
                InspectorLegacyModifier(
                    isPresented: isPresented,
                    inspectorContent: content
                )
            )
        }
    }

    /// Sobrecarga de onChange para compatibilidad con macOS 13
    @ViewBuilder
    func onSignumChange<V: Equatable>(
        of value: V,
        action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            // Versión Moderna (v26): Sin etiqueta 'action'
            self.onChange(of: value) { oldValue, newValue in
                action(oldValue, newValue)
            }
        } else {
            // Versión macOS 13: Usamos 'perform' y simulamos el flujo
            // Nota: Aquí 'value' representa el valor antes del cambio en el momento de la captura
            self.onChange(of: value) { newValue in
                action(value, newValue)
            }
        }
    }

    @ViewBuilder
    func signumSidebarToggle(hidden: Bool) -> some View {
        if #available(macOS 14.0, iOS 17.0, *) {
            // En versiones modernas (v26), podemos removerlo del todo
            self.toolbar(removing: hidden ? .sidebarToggle : nil)
        } else {
            // En macOS 13 no se puede remover fácilmente, pero podemos intentar mitigar su uso o dejarlo pasar por ahora si no es crítico
            self
        }
    }
}

struct InspectorLegacyModifier<InspectorContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let inspectorContent: () -> InspectorContent

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content

            if isPresented {
                Divider()
                inspectorContent()
                    .frame(width: 250)  // Ancho ideal para el inspector en macOS 13
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
