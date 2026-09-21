import Foundation

public struct PersonalRecords: Equatable, Sendable {
    public let bestWeight: Double
    public let bestReps: Int
    public let bestVolume: Double
    public let totalSessions: Int
}

public struct ExerciseProgressPoint: Identifiable, Equatable, Sendable {
    public let id = UUID()
    public let date: Date
    public let maxWeight: Double
    public let bestReps: Int
    public let totalVolume: Double
}

public struct WorkoutCalculations {
    
    // MARK: - Helper to filter valid recorded sets (no checkmark required)
    private static func validSets(in exercise: WorkoutExercise) -> [WorkoutSet] {
        exercise.sets.filter { $0.isCompleted || $0.weight > 0 || $0.reps > 0 }
    }
    
    // MARK: - Personal Records
    public static func calculatePRs(for exerciseId: UUID, in workouts: [Workout]) -> PersonalRecords {
        var maxWeight: Double = 0
        var maxReps: Int = 0
        var maxVolume: Double = 0
        var sessionCount: Int = 0
        
        for workout in workouts where workout.isCompleted {
            for exercise in workout.exercises where exercise.exerciseId == exerciseId {
                let sets = validSets(in: exercise)
                guard !sets.isEmpty else { continue }
                
                sessionCount += 1
                for set in sets {
                    if set.weight > maxWeight {
                        maxWeight = set.weight
                    }
                    if set.reps > maxReps {
                        maxReps = set.reps
                    }
                    let vol = set.volume
                    if vol > maxVolume {
                        maxVolume = vol
                    }
                }
            }
        }
        
        return PersonalRecords(
            bestWeight: maxWeight,
            bestReps: maxReps,
            bestVolume: maxVolume,
            totalSessions: sessionCount
        )
    }
    
    // MARK: - Progress Over Time for Charts
    public static func progressPoints(for exerciseId: UUID, in workouts: [Workout]) -> [ExerciseProgressPoint] {
        var points: [ExerciseProgressPoint] = []
        
        let sorted = workouts.filter { $0.isCompleted }.sorted { $0.date < $1.date }
        
        for workout in sorted {
            if let exercise = workout.exercises.first(where: { $0.exerciseId == exerciseId }) {
                let sets = validSets(in: exercise)
                if !sets.isEmpty {
                    let maxW = sets.map(\.weight).max() ?? 0
                    let bestR = sets.map(\.reps).max() ?? 0
                    let totalV = sets.reduce(0) { $0 + $1.volume }
                    points.append(ExerciseProgressPoint(
                        date: workout.date,
                        maxWeight: maxW,
                        bestReps: bestR,
                        totalVolume: totalV
                    ))
                }
            }
        }
        
        return points
    }
    
    // MARK: - Historical Exercise Sets (for Exercise Detail History)
    public static func sessions(for exerciseId: UUID, in workouts: [Workout]) -> [(workout: Workout, exercise: WorkoutExercise)] {
        var result: [(workout: Workout, exercise: WorkoutExercise)] = []
        let sorted = workouts.filter { $0.isCompleted }.sorted { $0.date > $1.date }
        for workout in sorted {
            if let exercise = workout.exercises.first(where: { $0.exerciseId == exerciseId }) {
                if !validSets(in: exercise).isEmpty {
                    result.append((workout: workout, exercise: exercise))
                }
            }
        }
        return result
    }
    
    // MARK: - Previous Workout Sets for Auto-Fill
    public static func previousSets(for exerciseId: UUID, in workouts: [Workout]) -> [WorkoutSet] {
        let sorted = workouts.filter { $0.isCompleted }.sorted { $0.date > $1.date }
        for workout in sorted {
            if let exercise = workout.exercises.first(where: { $0.exerciseId == exerciseId }) {
                let sets = validSets(in: exercise)
                if !sets.isEmpty {
                    return sets
                }
            }
        }
        return []
    }
    
    // MARK: - Formatting Helpers
    public static func formatWeight(_ weight: Double, unit: WeightUnit) -> String {
        let valString = weight.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", weight) : String(format: "%.1f", weight)
        return "\(valString) \(unit.rawValue)"
    }
    
    public static func formatVolume(_ volume: Double, unit: WeightUnit) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedNumber = formatter.string(from: NSNumber(value: volume)) ?? String(format: "%.0f", volume)
        return "\(formattedNumber) \(unit.rawValue)"
    }
}
