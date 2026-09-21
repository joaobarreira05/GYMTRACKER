import Foundation

public struct WorkoutSet: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var setNumber: Int
    public var weight: Double
    public var reps: Int
    public var isCompleted: Bool
    public var timestamp: Date
    public var rir: Int? // Reps in Reserve (optional)
    public var previousWeight: Double?
    public var previousReps: Int?
    
    public init(
        id: UUID = UUID(),
        setNumber: Int,
        weight: Double = 0.0,
        reps: Int = 0,
        isCompleted: Bool = false,
        timestamp: Date = Date(),
        rir: Int? = nil,
        previousWeight: Double? = nil,
        previousReps: Int? = nil
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.timestamp = timestamp
        self.rir = rir
        self.previousWeight = previousWeight
        self.previousReps = previousReps
    }
    
    public var volume: Double {
        return weight * Double(reps)
    }
    
    public var previousDisplayString: String {
        if let pw = previousWeight, let pr = previousReps {
            let weightString = pw.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", pw) : String(format: "%.1f", pw)
            return "\(weightString) × \(pr)"
        }
        return "—"
    }
}
