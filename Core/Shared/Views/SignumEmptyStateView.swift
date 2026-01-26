//
//  SignumEmptyStateView.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

struct SignumEmptyStateView: View {
    let title: String
        let systemImage: String
        let description: String
        var actionLabel: String? = nil
        var action: (() -> Void)? = nil
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: systemImage)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                if let label = actionLabel, let action = action {
                    Button(action: action) {
                        Text(label)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 100)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
}

#Preview("Empty State Preview") {
    SignumEmptyStateView(
        title: "No Items",
        systemImage: "tray",
        description: "There are no items to display right now. Add a new item to get started."
    )
    .padding()
}

#Preview("Empty State Preview (conBotón)") {
    SignumEmptyStateView(
        title: "No Items",
        systemImage: "tray",
        description: "There are no items to display right now. Add a new item to get started.",
        actionLabel: "Add Item",
        action: { print("Add Item tapped") }
    )
    .padding()
}
