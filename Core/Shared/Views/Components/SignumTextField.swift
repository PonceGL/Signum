//
//  SignumTextField.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 02/02/26.
//

import SwiftUI

struct SignumTextField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil
    #if os(iOS)
        var keyboardType: UIKeyboardType = .default
        var contentType: UITextContentType? = nil
    #endif

    var body: some View {
        TextField(title, text: $text)
            #if os(iOS)
                .keyboardType(keyboardType)
                .textContentType(contentType)
            #endif
            .signumInput(icon: icon)
    }
}

#Preview {
    VStack(spacing: 20) {
        SignumTextField(
            title: "Nombre",
            text: .constant(""),
        )

        SignumTextField(
            title: "Correo Electrónico",
            text: .constant(""),
            icon: "envelope",
        )
        #if os(iOS)
            SignumTextField(
                title: "Correo Electrónico",
                text: .constant(""),
                icon: "envelope",
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )
        #endif

    }
}
