//
//  EnvironmentManager.swift
//  Signum
//
//  Created by Ponciano Guevara Lozano on 23/01/26.
//

import Foundation

import Foundation

public enum EnvironmentKey: String {
    case appName = "CFBundleName"
    case bundleId = "CFBundleIdentifier"
}

public struct EnvironmentManager {
    
    public static let shared = EnvironmentManager()
    
    private init() {}
    
    public func get(_ key: EnvironmentKey) -> String {
        guard let dict = Bundle.main.infoDictionary,
              let value = dict[key.rawValue] as? String else {
            fatalError("🔥 Error Crítico: No se encontró la configuración para '\(key.rawValue)' en el Info.plist. Verifica tus archivos .xcconfig.")
        }
        return value
    }
    
    /// Variable computada para saber si estamos en modo Debug o Release a nivel de compilador
    public var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
