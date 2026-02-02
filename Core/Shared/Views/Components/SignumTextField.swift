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
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(keyboardType)
            .textContentType(contentType)
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
            keyboardType: .emailAddress,
            contentType: .emailAddress
        )

    }
}
