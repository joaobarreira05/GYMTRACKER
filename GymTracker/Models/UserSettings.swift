import Foundation
import SwiftUI

public enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case kg = "kg"
    case lb = "lb"
}

public enum AppAppearance: String, Codable, CaseIterable, Sendable {
    case system = "System"
    case dark = "Dark"
    case light = "Light"
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

public struct UserSettings: Codable, Sendable {
    public var weightUnit: WeightUnit
    public var appearance: AppAppearance
    public var defaultRestDuration: Int // in seconds
    public var autoStartRestTimer: Bool
    public var userName: String
    
    public init(
        weightUnit: WeightUnit = .kg,
        appearance: AppAppearance = .dark,
        defaultRestDuration: Int = 120,
        autoStartRestTimer: Bool = true,
        userName: String = "João"
    ) {
        self.weightUnit = weightUnit
        self.appearance = appearance
        self.defaultRestDuration = defaultRestDuration
        self.autoStartRestTimer = autoStartRestTimer
        self.userName = userName
    }
}
