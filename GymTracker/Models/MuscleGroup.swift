import Foundation
import SwiftUI

public enum MuscleGroup: String, Codable, CaseIterable, Identifiable, Sendable {
    case chest = "Chest"
    case shoulders = "Shoulders"
    case back = "Back"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case quads = "Legs — Quadriceps"
    case hamstringsGlutes = "Hamstrings / Glutes"
    case calves = "Calves"
    case absCore = "Abs / Core"
    case other = "Other / Full Body"
    
    public var id: String { rawValue }
    
    public var shortName: String {
        switch self {
        case .chest: return "Chest"
        case .shoulders: return "Shoulders"
        case .back: return "Back"
        case .biceps: return "Biceps"
        case .triceps: return "Triceps"
        case .quads: return "Quads"
        case .hamstringsGlutes: return "Hamstrings"
        case .calves: return "Calves"
        case .absCore: return "Core"
        case .other: return "Other"
        }
    }
    
    public var shortPortugueseName: String {
        switch self {
        case .chest: return "Peito"
        case .shoulders: return "Ombros"
        case .back: return "Costas"
        case .biceps: return "Bíceps"
        case .triceps: return "Tríceps"
        case .quads: return "Pernas"
        case .hamstringsGlutes: return "Posterior"
        case .calves: return "Gémeos"
        case .absCore: return "Abdominais"
        case .other: return "Geral"
        }
    }
    
    public var iconName: String {
        switch self {
        case .chest: return "shield.fill"
        case .shoulders: return "person.bust.fill"
        case .back: return "figure.walk"
        case .biceps: return "dumbbell.fill"
        case .triceps: return "bolt.shield.fill"
        case .quads: return "figure.run"
        case .hamstringsGlutes: return "figure.strengthtraining.traditional"
        case .calves: return "shoeprints.fill"
        case .absCore: return "circle.hexagongrid.fill"
        case .other: return "flame.fill"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .chest: return .blue
        case .shoulders: return .orange
        case .back: return .teal
        case .biceps: return .purple
        case .triceps: return .indigo
        case .quads: return .red
        case .hamstringsGlutes: return .pink
        case .calves: return .green
        case .absCore: return .yellow
        case .other: return .gray
        }
    }
}
