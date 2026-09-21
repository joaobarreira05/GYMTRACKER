import Foundation

public final class DataManager: @unchecked Sendable {
    public static let shared = DataManager()
    
    private let fileManager = FileManager.default
    
    private var baseDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls[0].appendingPathComponent("GymTracker", isDirectory: true)
        if !fileManager.fileExists(atPath: appSupport.path) {
            try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        }
        return appSupport
    }
    
    private var exercisesFileURL: URL {
        baseDirectory.appendingPathComponent("exercises.json")
    }
    
    private var workoutsFileURL: URL {
        baseDirectory.appendingPathComponent("workouts.json")
    }
    
    private var activeWorkoutFileURL: URL {
        baseDirectory.appendingPathComponent("active_workout.json")
    }
    
    private var templatesFileURL: URL {
        baseDirectory.appendingPathComponent("templates.json")
    }
    
    private var settingsFileURL: URL {
        baseDirectory.appendingPathComponent("settings.json")
    }
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {}
    
    // MARK: - Exercises
    public func loadExercises() -> [Exercise] {
        if let data = try? Data(contentsOf: exercisesFileURL),
           let list = try? decoder.decode([Exercise].self, from: data), !list.isEmpty {
            return list
        }
        let initial = SeedData.initialExercises
        saveExercises(initial)
        return initial
    }
    
    public func saveExercises(_ exercises: [Exercise]) {
        do {
            let data = try encoder.encode(exercises)
            try data.write(to: exercisesFileURL, options: .atomic)
        } catch {
            print("Failed to save exercises: \(error)")
        }
    }
    
    // MARK: - Workouts (History)
    public func loadWorkouts() -> [Workout] {
        guard let data = try? Data(contentsOf: workoutsFileURL),
              let list = try? decoder.decode([Workout].self, from: data) else {
            return []
        }
        return list.sorted { $0.date > $1.date }
    }
    
    public func saveWorkouts(_ workouts: [Workout]) {
        do {
            let data = try encoder.encode(workouts)
            try data.write(to: workoutsFileURL, options: .atomic)
        } catch {
            print("Failed to save workouts: \(error)")
        }
    }
    
    // MARK: - Active Workout (In-Progress)
    public func loadActiveWorkout() -> Workout? {
        guard fileManager.fileExists(atPath: activeWorkoutFileURL.path),
              let data = try? Data(contentsOf: activeWorkoutFileURL),
              let workout = try? decoder.decode(Workout.self, from: data) else {
            return nil
        }
        return workout
    }
    
    public func saveActiveWorkout(_ workout: Workout?) {
        guard let workout = workout else {
            clearActiveWorkout()
            return
        }
        do {
            let data = try encoder.encode(workout)
            try data.write(to: activeWorkoutFileURL, options: .atomic)
        } catch {
            print("Failed to save active workout: \(error)")
        }
    }
    
    public func clearActiveWorkout() {
        try? fileManager.removeItem(at: activeWorkoutFileURL)
    }
    
    // MARK: - Templates
    public func loadTemplates(exercises: [Exercise]) -> [WorkoutTemplate] {
        if let data = try? Data(contentsOf: templatesFileURL),
           let list = try? decoder.decode([WorkoutTemplate].self, from: data), !list.isEmpty {
            return list
        }
        let initial = SeedData.defaultTemplates(for: exercises)
        saveTemplates(initial)
        return initial
    }
    
    public func saveTemplates(_ templates: [WorkoutTemplate]) {
        do {
            let data = try encoder.encode(templates)
            try data.write(to: templatesFileURL, options: .atomic)
        } catch {
            print("Failed to save templates: \(error)")
        }
    }
    
    // MARK: - Settings
    public func loadSettings() -> UserSettings {
        if let data = try? Data(contentsOf: settingsFileURL),
           let settings = try? decoder.decode(UserSettings.self, from: data) {
            return settings
        }
        let initial = UserSettings()
        saveSettings(initial)
        return initial
    }
    
    public func saveSettings(_ settings: UserSettings) {
        do {
            let data = try encoder.encode(settings)
            try data.write(to: settingsFileURL, options: .atomic)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    // MARK: - Export Data (Local Only)
    public func exportDataAsJSON(workouts: [Workout], exercises: [Exercise]) -> URL? {
        struct ExportPayload: Codable {
            let exportDate: Date
            let appVersion: String
            let workoutsCount: Int
            let exercisesCount: Int
            let workouts: [Workout]
            let exercises: [Exercise]
        }
        
        let payload = ExportPayload(
            exportDate: Date(),
            appVersion: "1.0",
            workoutsCount: workouts.count,
            exercisesCount: exercises.count,
            workouts: workouts,
            exercises: exercises
        )
        
        guard let data = try? encoder.encode(payload) else { return nil }
        
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("GymTracker_Export_\(Int(Date().timeIntervalSince1970)).json")
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            print("Failed to export JSON: \(error)")
            return nil
        }
    }
}
