import Foundation

public struct Exercise: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var muscleGroup: MuscleGroup
    public var isCustom: Bool
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        isCustom: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.notes = notes
    }
}
