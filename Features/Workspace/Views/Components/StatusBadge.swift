//
//  StatusBadge.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import SwiftUI

struct StatusBadge: View {
    let status: DocumentStatus
        
        var body: some View {
            Group {
                switch status {
                case .pending:
                    Circle()
                        .stroke(Color.secondary, lineWidth: 2)
                        .frame(width: 12, height: 12)
                case .analyzing:
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                case .needsReview:
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                case .verified:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                case .renamed:
                    Image(systemName: "doc.badge.checkmark.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                }
            }
        }
}

#Preview("Estados del Badge") {
    VStack(spacing: 20) {
        StatusBadge(status: .pending)
        StatusBadge(status: .analyzing)
        StatusBadge(status: .needsReview)
        StatusBadge(status: .verified)
        StatusBadge(status: .error)
    }
    .padding()
}
