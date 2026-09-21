import Foundation

public struct WorkoutTemplate: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var notes: String?
    public var exerciseIds: [UUID]
    public var isCustom: Bool
    
    public init(
        id: UUID = UUID(),
        name: String,
        notes: String? = nil,
        exerciseIds: [UUID] = [],
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.exerciseIds = exerciseIds
        self.isCustom = isCustom
    }
}
