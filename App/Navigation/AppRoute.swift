//
//  AppRoute.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation
import SwiftUI

enum AppRoute: String, CaseIterable, Identifiable {
    case scanner
    case pdfTools
    case history
    case userProfile

    var id: String { self.rawValue }

    /// Título visible en la UI
    var title: String {
        switch self {
        case .scanner: return "Nuevo Escaneo"
        case .pdfTools: return "Utilidad de PDF"
        case .history: return "Historial"
        case .userProfile: return "Perfil de Usuario"
        }
    }

    /// Icono SF Symbol asociado
    var iconName: String {
        switch self {
        case .scanner: return "doc.viewfinder"
        case .pdfTools: return "document.badge.gearshape"
        case .history: return "clock.arrow.circlepath"
        case .userProfile: return "person.crop.circle"
        }
    }
}
