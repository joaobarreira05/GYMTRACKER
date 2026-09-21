import Foundation
import SwiftUI
import Combine

@MainActor
public final class GymStore: ObservableObject {
    public static let shared = GymStore()
    
    @Published public var exercises: [Exercise] = []
    @Published public var workouts: [Workout] = []
    @Published public var templates: [WorkoutTemplate] = []
    @Published public var settings: UserSettings = UserSettings()
    @Published public var activeWorkout: Workout? = nil
    @Published public var selectedTab: Int = 1 // Defaults to Workout tab (the daily notebook)
    
    private let dataManager = DataManager.shared
    
    public init() {
        loadAllData()
    }
    
    public func loadAllData() {
        self.exercises = dataManager.loadExercises()
        self.workouts = dataManager.loadWorkouts()
        self.templates = dataManager.loadTemplates(exercises: self.exercises)
        self.settings = dataManager.loadSettings()
        
        // Find or create today's workout sheet
        let calendar = Calendar.current
        if let existingToday = workouts.first(where: { calendar.isDateInToday($0.date) }) {
            self.activeWorkout = existingToday
        } else if let savedActive = dataManager.loadActiveWorkout(), calendar.isDateInToday(savedActive.date) {
            self.activeWorkout = savedActive
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "pt_PT")
            formatter.dateFormat = "d MMM"
            let defaultName = "Treino — \(formatter.string(from: Date()))"
            let newToday = Workout(name: defaultName, date: Date(), exercises: [])
            self.activeWorkout = newToday
        }
    }
    
    private func persistToday() {
        guard let current = activeWorkout else { return }
        
        // Update in workouts history list
        if let idx = workouts.firstIndex(where: { $0.id == current.id }) {
            workouts[idx] = current
        } else {
            workouts.insert(current, at: 0)
        }
        
        // Keep sorted by date
        workouts.sort { $0.date > $1.date }
        
        dataManager.saveWorkouts(workouts)
        dataManager.saveActiveWorkout(current)
    }
    
    // MARK: - Daily Notebook Operations
    public func addExerciseToActiveWorkout(_ exercise: Exercise) {
        if activeWorkout == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            activeWorkout = Workout(name: "Treino — \(formatter.string(from: Date()))", date: Date(), exercises: [])
        }
        guard var current = activeWorkout else { return }
        
        // Find previous workout sets for reference
        let prevSets = WorkoutCalculations.previousSets(for: exercise.id, in: workouts.filter { $0.id != current.id })
        var sets: [WorkoutSet] = []
        if !prevSets.isEmpty {
            for (idx, prev) in prevSets.enumerated() {
                sets.append(WorkoutSet(
                    setNumber: idx + 1,
                    weight: prev.weight,
                    reps: prev.reps,
                    isCompleted: false,
                    previousWeight: prev.weight,
                    previousReps: prev.reps
                ))
            }
        } else {
            sets = [
                WorkoutSet(setNumber: 1, weight: 0, reps: 0, isCompleted: false),
                WorkoutSet(setNumber: 2, weight: 0, reps: 0, isCompleted: false),
                WorkoutSet(setNumber: 3, weight: 0, reps: 0, isCompleted: false)
            ]
        }
        
        let workoutExercise = WorkoutExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            muscleGroup: exercise.muscleGroup,
            orderIndex: current.exercises.count,
            sets: sets
        )
        
        current.exercises.append(workoutExercise)
        self.activeWorkout = current
        persistToday()
        HapticFeedback.light()
    }
    
    public func removeExerciseFromActiveWorkout(at index: Int) {
        guard var current = activeWorkout, current.exercises.indices.contains(index) else { return }
        current.exercises.remove(at: index)
        for i in 0..<current.exercises.count {
            current.exercises[i].orderIndex = i
        }
        self.activeWorkout = current
        persistToday()
        HapticFeedback.light()
    }
    
    public func addSet(to exerciseIndex: Int) {
        guard var current = activeWorkout, current.exercises.indices.contains(exerciseIndex) else { return }
        let existingSets = current.exercises[exerciseIndex].sets
        let nextSetNum = existingSets.count + 1
        
        let lastWeight = existingSets.last?.weight ?? 0
        let lastReps = existingSets.last?.reps ?? 0
        
        let newSet = WorkoutSet(
            setNumber: nextSetNum,
            weight: lastWeight,
            reps: lastReps,
            isCompleted: false,
            previousWeight: existingSets.last?.previousWeight,
            previousReps: existingSets.last?.previousReps
        )
        
        current.exercises[exerciseIndex].sets.append(newSet)
        self.activeWorkout = current
        persistToday()
        HapticFeedback.light()
    }
    
    public func removeSet(exerciseIndex: Int, setIndex: Int) {
        guard var current = activeWorkout,
              current.exercises.indices.contains(exerciseIndex),
              current.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        current.exercises[exerciseIndex].sets.remove(at: setIndex)
        for i in 0..<current.exercises[exerciseIndex].sets.count {
            current.exercises[exerciseIndex].sets[i].setNumber = i + 1
        }
        
        self.activeWorkout = current
        persistToday()
        HapticFeedback.light()
    }
    
    public func toggleSetCompleted(exerciseIndex: Int, setIndex: Int) {
        guard var current = activeWorkout,
              current.exercises.indices.contains(exerciseIndex),
              current.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        let wasCompleted = current.exercises[exerciseIndex].sets[setIndex].isCompleted
        current.exercises[exerciseIndex].sets[setIndex].isCompleted = !wasCompleted
        current.exercises[exerciseIndex].sets[setIndex].timestamp = Date()
        
        self.activeWorkout = current
        persistToday()
        HapticFeedback.light()
    }
    
    public func updateSet(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        guard var current = activeWorkout,
              current.exercises.indices.contains(exerciseIndex),
              current.exercises[exerciseIndex].sets.indices.contains(setIndex) else { return }
        
        current.exercises[exerciseIndex].sets[setIndex].weight = max(0, weight)
        current.exercises[exerciseIndex].sets[setIndex].reps = max(0, reps)
        
        self.activeWorkout = current
        persistToday()
    }
    
    public func updateExerciseNotes(exerciseIndex: Int, notes: String) {
        guard var current = activeWorkout, current.exercises.indices.contains(exerciseIndex) else { return }
        current.exercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        self.activeWorkout = current
        persistToday()
    }
    
    public func updateWorkoutNotes(notes: String) {
        guard var current = activeWorkout else { return }
        current.notes = notes.isEmpty ? nil : notes
        self.activeWorkout = current
        persistToday()
    }
    
    public func updateWorkoutName(name: String) {
        guard var current = activeWorkout else { return }
        current.name = name
        self.activeWorkout = current
        persistToday()
    }
    
    public func clearTodayWorkout() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        let defaultName = "Treino — \(formatter.string(from: Date()))"
        let cleared = Workout(name: defaultName, date: Date(), exercises: [])
        self.activeWorkout = cleared
        persistToday()
        RestTimerManager.shared.stop()
        HapticFeedback.warning()
    }
    
    // MARK: - Copy Past Workout or Template into Today
    public func copyWorkoutToToday(_ pastWorkout: Workout) {
        var copiedExercises: [WorkoutExercise] = []
        
        for (idx, oldEx) in pastWorkout.exercises.enumerated() {
            var newSets: [WorkoutSet] = []
            for (setIdx, oldSet) in oldEx.sets.enumerated() {
                newSets.append(WorkoutSet(
                    setNumber: setIdx + 1,
                    weight: oldSet.weight,
                    reps: oldSet.reps,
                    isCompleted: false,
                    timestamp: Date(),
                    rir: oldSet.rir,
                    previousWeight: oldSet.weight,
                    previousReps: oldSet.reps
                ))
            }
            if newSets.isEmpty {
                newSets = [WorkoutSet(setNumber: 1, weight: 0, reps: 0, isCompleted: false)]
            }
            copiedExercises.append(WorkoutExercise(
                exerciseId: oldEx.exerciseId,
                exerciseName: oldEx.exerciseName,
                muscleGroup: oldEx.muscleGroup,
                orderIndex: idx,
                sets: newSets,
                notes: oldEx.notes
            ))
        }
        
        let updated = Workout(
            id: activeWorkout?.id ?? UUID(),
            name: pastWorkout.name,
            date: Date(),
            exercises: copiedExercises,
            notes: pastWorkout.notes,
            templateId: pastWorkout.templateId
        )
        
        self.activeWorkout = updated
        persistToday()
        self.selectedTab = 1 // Switch to Workout notebook tab
        HapticFeedback.success()
    }
    
    public func loadTemplateIntoToday(_ template: WorkoutTemplate) {
        var initialExercises: [WorkoutExercise] = []
        for (idx, exId) in template.exerciseIds.enumerated() {
            if let exercise = exercises.first(where: { $0.id == exId }) {
                let prevSets = WorkoutCalculations.previousSets(for: exercise.id, in: workouts)
                var sets: [WorkoutSet] = []
                if !prevSets.isEmpty {
                    for (setIdx, prev) in prevSets.enumerated() {
                        sets.append(WorkoutSet(
                            setNumber: setIdx + 1,
                            weight: prev.weight,
                            reps: prev.reps,
                            isCompleted: false,
                            previousWeight: prev.weight,
                            previousReps: prev.reps
                        ))
                    }
                } else {
                    sets = [
                        WorkoutSet(setNumber: 1, weight: 0, reps: 0, isCompleted: false),
                        WorkoutSet(setNumber: 2, weight: 0, reps: 0, isCompleted: false),
                        WorkoutSet(setNumber: 3, weight: 0, reps: 0, isCompleted: false)
                    ]
                }
                
                initialExercises.append(WorkoutExercise(
                    exerciseId: exercise.id,
                    exerciseName: exercise.name,
                    muscleGroup: exercise.muscleGroup,
                    orderIndex: idx,
                    sets: sets
                ))
            }
        }
        
        let updated = Workout(
            id: activeWorkout?.id ?? UUID(),
            name: template.name,
            date: Date(),
            exercises: initialExercises,
            notes: template.notes,
            templateId: template.id
        )
        
        self.activeWorkout = updated
        persistToday()
        self.selectedTab = 1
        HapticFeedback.success()
    }
    
    // MARK: - Historical Editing
    public func updateHistoricalWorkout(_ updated: Workout) {
        if let idx = workouts.firstIndex(where: { $0.id == updated.id }) {
            workouts[idx] = updated
            workouts.sort { $0.date > $1.date }
            dataManager.saveWorkouts(workouts)
            if activeWorkout?.id == updated.id {
                activeWorkout = updated
            }
            HapticFeedback.success()
        }
    }
    
    public func deleteWorkoutFromHistory(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        dataManager.saveWorkouts(workouts)
        if activeWorkout?.id == workout.id {
            clearTodayWorkout()
        }
        HapticFeedback.light()
    }
    
    // MARK: - Library & Templates
    public func addCustomExercise(name: String, muscleGroup: MuscleGroup) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newEx = Exercise(name: trimmed, muscleGroup: muscleGroup, isCustom: true)
        exercises.append(newEx)
        exercises.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        dataManager.saveExercises(exercises)
        HapticFeedback.light()
    }
    
    public func deleteCustomExercise(_ exercise: Exercise) {
        guard exercise.isCustom else { return }
        exercises.removeAll { $0.id == exercise.id }
        dataManager.saveExercises(exercises)
        HapticFeedback.light()
    }
    
    public func saveTemplate(_ template: WorkoutTemplate) {
        if let idx = templates.firstIndex(where: { $0.id == template.id }) {
            templates[idx] = template
        } else {
            templates.append(template)
        }
        dataManager.saveTemplates(templates)
        HapticFeedback.light()
    }
    
    public func deleteTemplate(_ template: WorkoutTemplate) {
        templates.removeAll { $0.id == template.id }
        dataManager.saveTemplates(templates)
        HapticFeedback.light()
    }
    
    public func updateSettings(_ newSettings: UserSettings) {
        self.settings = newSettings
        dataManager.saveSettings(newSettings)
    }
    
    public func exportData() -> URL? {
        dataManager.exportDataAsJSON(workouts: workouts, exercises: exercises)
    }
}
