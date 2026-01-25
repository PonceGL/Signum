//
//  AppRoute.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 25/01/26.
//

import Foundation
import SwiftUI

enum AppRoute: String, CaseIterable, Identifiable {
    case dashboard
    case scanner
    case history
    case settings

    var id: String { self.rawValue }

    /// Título visible en la UI
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .scanner: return "Nuevo Escaneo"
        case .history: return "Historial"
        case .settings: return "Configuración"
        }
    }

    /// Icono SF Symbol asociado
    var iconName: String {
        switch self {
        case .dashboard: return "chart.bar.doc.horizontal"
        case .scanner: return "doc.viewfinder"  // Icono central de nuestra app
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        }
    }
}
