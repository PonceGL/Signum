//
//  ImportAlert.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 09/02/26.
//

import Foundation

/// Configuración para alertas de importación
struct ImportAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let actions: [AlertAction]
    
    struct AlertAction: Identifiable {
        let id = UUID()
        let title: String
        let style: ActionStyle
        let handler: () -> Void
        
        enum ActionStyle {
            case `default`
            case cancel
            case destructive
        }
    }
    
    /// Alerta simple con solo botón "OK"
    static func simple(title: String, message: String) -> ImportAlert {
        ImportAlert(
            title: title,
            message: message,
            actions: [
                AlertAction(title: "OK", style: .cancel, handler: {})
            ]
        )
    }
    
    /// Alerta para carpeta con subcarpetas (Caso C)
    static func folderWithSubfolders(
        folderName: String,
        subfolders: [URL],
        onExplore: @escaping ([URL]) -> Void
    ) -> ImportAlert {
        let subfolderNames = subfolders.prefix(3).map { $0.lastPathComponent }.joined(separator: ", ")
        let moreCount = max(0, subfolders.count - 3)
        let subfoldersText = moreCount > 0 ? "\(subfolderNames) y \(moreCount) más" : subfolderNames
        
        return ImportAlert(
            title: "Carpeta sin PDFs",
            message: "La carpeta '\(folderName)' no contiene PDFs en el nivel principal, pero tiene subcarpetas: \(subfoldersText).\n\n¿Deseas explorar las subcarpetas?",
            actions: [
                AlertAction(title: "Cancelar", style: .cancel, handler: {}),
                AlertAction(title: "Explorar", style: .default, handler: {
                    onExplore(subfolders)
                })
            ]
        )
    }
}
