import Foundation

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
}
