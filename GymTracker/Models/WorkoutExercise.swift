import Foundation

public struct WorkoutExercise: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var exerciseId: UUID
    public var exerciseName: String
    public var muscleGroup: MuscleGroup
    public var orderIndex: Int
    public var sets: [WorkoutSet]
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        exerciseId: UUID,
        exerciseName: String,
        muscleGroup: MuscleGroup,
        orderIndex: Int = 0,
        sets: [WorkoutSet] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.orderIndex = orderIndex
        self.sets = sets
        self.notes = notes
    }
    
    public var activeSets: [WorkoutSet] {
        sets.filter { $0.isCompleted || $0.weight > 0 || $0.reps > 0 }
    }
    
    public var totalVolume: Double {
        activeSets.reduce(0) { $0 + $1.volume }
    }
    
    public var completedSetsCount: Int {
        activeSets.count
    }
    
    public var maxWeight: Double {
        activeSets.map(\.weight).max() ?? 0.0
    }
    
    public var maxReps: Int {
        activeSets.map(\.reps).max() ?? 0
    }
}
