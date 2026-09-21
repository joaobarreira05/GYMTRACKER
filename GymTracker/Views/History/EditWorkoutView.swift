import SwiftUI

public struct EditWorkoutView: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var workout: Workout
    @State private var isShowingExercisePicker: Bool = false
    
    public init(workout: Workout) {
        _workout = State(initialValue: workout)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Card (Name, Date, Notes)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workout Information")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        TextField("Workout Name", text: $workout.name)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .padding(10)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        DatePicker("Date & Time", selection: $workout.date)
                            .font(.subheadline)
                        
                        TextField("Notes (optional)...", text: Binding(
                            get: { workout.notes ?? "" },
                            set: { workout.notes = $0.isEmpty ? nil : $0 }
                        ))
                        .font(.footnote)
                        .padding(10)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    
                    // Exercises List
                    VStack(spacing: 14) {
                        ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { (exIdx, exercise) in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.exerciseName)
                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                        
                                        Label(exercise.muscleGroup.shortName, systemImage: exercise.muscleGroup.iconName)
                                            .font(.caption2.bold())
                                            .foregroundStyle(exercise.muscleGroup.themeColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(role: .destructive) {
                                        workout.exercises.remove(at: exIdx)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.subheadline)
                                            .foregroundStyle(.red)
                                    }
                                }
                                
                                // Exercise direct notes
                                HStack(spacing: 6) {
                                    Image(systemName: "note.text")
                                        .font(.caption)
                                        .foregroundStyle(exercise.notes?.isEmpty == false ? Color.accentColor : Color.secondary)
                                    
                                    TextField("Add notes/comment (e.g. seat 4)...", text: Binding(
                                        get: { exercise.notes ?? "" },
                                        set: { workout.exercises[exIdx].notes = $0.isEmpty ? nil : $0 }
                                    ))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    
                                    if let n = exercise.notes, !n.isEmpty {
                                        Button {
                                            workout.exercises[exIdx].notes = nil
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                
                                // Table Header
                                HStack(spacing: 8) {
                                    Text("SET")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, alignment: .center)
                                    
                                    Text("PREVIOUS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text(gymStore.settings.weightUnit.rawValue.uppercased())
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 72, alignment: .center)
                                    
                                    Text("REPS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 60, alignment: .center)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 44, alignment: .center)
                                }
                                .padding(.horizontal, 10)
                                
                                // Sets
                                VStack(spacing: 6) {
                                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { (setIdx, set) in
                                        SetRowView(
                                            setNumber: set.setNumber,
                                            previousString: set.previousDisplayString,
                                            weight: Binding(
                                                get: {
                                                    guard workout.exercises.indices.contains(exIdx),
                                                          workout.exercises[exIdx].sets.indices.contains(setIdx) else { return 0 }
                                                    return workout.exercises[exIdx].sets[setIdx].weight
                                                },
                                                set: { newW in
                                                    if workout.exercises.indices.contains(exIdx),
                                                       workout.exercises[exIdx].sets.indices.contains(setIdx) {
                                                        workout.exercises[exIdx].sets[setIdx].weight = newW
                                                    }
                                                }
                                            ),
                                            reps: Binding(
                                                get: {
                                                    guard workout.exercises.indices.contains(exIdx),
                                                          workout.exercises[exIdx].sets.indices.contains(setIdx) else { return 0 }
                                                    return workout.exercises[exIdx].sets[setIdx].reps
                                                },
                                                set: { newR in
                                                    if workout.exercises.indices.contains(exIdx),
                                                       workout.exercises[exIdx].sets.indices.contains(setIdx) {
                                                        workout.exercises[exIdx].sets[setIdx].reps = newR
                                                    }
                                                }
                                            ),
                                            isCompleted: set.isCompleted,
                                            unit: gymStore.settings.weightUnit,
                                            onToggleComplete: {
                                                if workout.exercises.indices.contains(exIdx),
                                                   workout.exercises[exIdx].sets.indices.contains(setIdx) {
                                                    workout.exercises[exIdx].sets[setIdx].isCompleted.toggle()
                                                    HapticFeedback.light()
                                                }
                                            },
                                            onDelete: {
                                                if workout.exercises.indices.contains(exIdx),
                                                   workout.exercises[exIdx].sets.indices.contains(setIdx) {
                                                    workout.exercises[exIdx].sets.remove(at: setIdx)
                                                    for i in 0..<workout.exercises[exIdx].sets.count {
                                                        workout.exercises[exIdx].sets[i].setNumber = i + 1
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                                
                                // Add Set
                                Button {
                                    let lastW = exercise.sets.last?.weight ?? 0
                                    let lastR = exercise.sets.last?.reps ?? 0
                                    let newSet = WorkoutSet(
                                        setNumber: exercise.sets.count + 1,
                                        weight: lastW,
                                        reps: lastR,
                                        isCompleted: true
                                    )
                                    workout.exercises[exIdx].sets.append(newSet)
                                    HapticFeedback.light()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Set")
                                    }
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Add Exercise Button
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        gymStore.updateHistoricalWorkout(workout)
                        dismiss()
                    }
                    .font(.headline.bold())
                }
            }
            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerSheet { ex in
                    let newEx = WorkoutExercise(
                        exerciseId: ex.id,
                        exerciseName: ex.name,
                        muscleGroup: ex.muscleGroup,
                        orderIndex: workout.exercises.count,
                        sets: [WorkoutSet(setNumber: 1, weight: 0, reps: 0, isCompleted: true)]
                    )
                    workout.exercises.append(newEx)
                }
            }
        }
    }
}
