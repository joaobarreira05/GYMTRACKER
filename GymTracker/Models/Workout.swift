import Foundation
import SwiftUI

public struct Workout: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var date: Date
    public var exercises: [WorkoutExercise]
    public var notes: String?
    public var templateId: UUID?
    
    // Legacy fields for backward compatibility with saved JSON
    public var startTime: Date?
    public var endTime: Date?
    public var isCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        name: String = "Today's Workout",
        date: Date = Date(),
        exercises: [WorkoutExercise] = [],
        notes: String? = nil,
        templateId: UUID? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        isCompleted: Bool = true
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.exercises = exercises
        self.notes = notes
        self.templateId = templateId
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }
    
    public var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    public var totalCompletedSets: Int {
        exercises.reduce(0) { $0 + $1.completedSetsCount }
    }
    
    public var totalExercisesCount: Int {
        exercises.count
    }
    
    // MARK: - Muscle Group Breakdown & Dominant Muscle
    public struct MuscleGroupSetCount: Identifiable, Hashable, Sendable {
        public var id: MuscleGroup { muscle }
        public let muscle: MuscleGroup
        public let setCount: Int
    }
    
    public var muscleBreakdown: [MuscleGroupSetCount] {
        var counts: [MuscleGroup: Int] = [:]
        for ex in exercises {
            let valid = ex.sets.filter { $0.isCompleted || $0.weight > 0 || $0.reps > 0 }
            let count = valid.isEmpty ? ex.sets.count : valid.count
            counts[ex.muscleGroup, default: 0] += count
        }
        return counts.map { MuscleGroupSetCount(muscle: $0.key, setCount: $0.value) }
            .sorted { $0.setCount > $1.setCount }
    }
    
    public var dominantMuscleGroup: MuscleGroup? {
        muscleBreakdown.first?.muscle
    }
    
    public var dominantMuscleColor: Color {
        dominantMuscleGroup?.themeColor ?? .blue
    }
    
    public var isGenericTitle: Bool {
        let lower = name.lowercased()
        return lower.hasPrefix("treino —") || lower.hasPrefix("treino -") ||
               lower.hasPrefix("workout —") || lower.hasPrefix("workout -") ||
               lower.hasPrefix("treino de hoje") || lower.hasPrefix("today's workout")
    }
    
    public var smartTitle: String {
        if isGenericTitle, let dominant = dominantMuscleGroup {
            let topMuscles = muscleBreakdown.prefix(2).map(\.muscle.shortPortugueseName).joined(separator: " & ")
            return topMuscles
        }
        return name
    }
}
