import SwiftUI

public struct WorkoutExerciseCard: View {
    @ObservedObject var gymStore = GymStore.shared
    let exerciseIndex: Int
    let onRemove: () -> Void
    
    private var exercise: WorkoutExercise? {
        guard gymStore.activeWorkout?.exercises.indices.contains(exerciseIndex) == true else { return nil }
        return gymStore.activeWorkout?.exercises[exerciseIndex]
    }
    
    public var body: some View {
        if let ex = exercise {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Name, Badge, Delete
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ex.exerciseName)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            Label(ex.muscleGroup.shortName, systemImage: ex.muscleGroup.iconName)
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(ex.muscleGroup.themeColor.opacity(0.15))
                                .foregroundStyle(ex.muscleGroup.themeColor)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        onRemove()
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
                
                // Direct Inline Notes / Comment Field (Always Visible)
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundStyle(ex.notes?.isEmpty == false ? Color.accentColor : Color.secondary)
                    
                    TextField("Add notes/comment (e.g. bench pin 3)...", text: Binding(
                        get: { ex.notes ?? "" },
                        set: { gymStore.updateExerciseNotes(exerciseIndex: exerciseIndex, notes: $0) }
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    
                    if let n = ex.notes, !n.isEmpty {
                        Button {
                            gymStore.updateExerciseNotes(exerciseIndex: exerciseIndex, notes: "")
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
                
                // Table Headers
                HStack(spacing: 8) {
                    Text("SET")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, alignment: .center)
                    
                    Text("PREVIOUS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(gymStore.settings.weightUnit.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 72, alignment: .center)
                    
                    Text("REPS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .center)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .center)
                }
                .padding(.horizontal, 10)
                
                // Sets Rows
                VStack(spacing: 6) {
                    ForEach(Array(ex.sets.enumerated()), id: \.element.id) { (setIndex, set) in
                        SetRowView(
                            setNumber: set.setNumber,
                            previousString: set.previousDisplayString,
                            weight: Binding(
                                get: {
                                    guard gymStore.activeWorkout?.exercises[exerciseIndex].sets.indices.contains(setIndex) == true else { return 0 }
                                    return gymStore.activeWorkout?.exercises[exerciseIndex].sets[setIndex].weight ?? 0
                                },
                                set: { newW in
                                    guard let reps = gymStore.activeWorkout?.exercises[exerciseIndex].sets[setIndex].reps else { return }
                                    gymStore.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: newW, reps: reps)
                                }
                            ),
                            reps: Binding(
                                get: {
                                    guard gymStore.activeWorkout?.exercises[exerciseIndex].sets.indices.contains(setIndex) == true else { return 0 }
                                    return gymStore.activeWorkout?.exercises[exerciseIndex].sets[setIndex].reps ?? 0
                                },
                                set: { newR in
                                    guard let weight = gymStore.activeWorkout?.exercises[exerciseIndex].sets[setIndex].weight else { return }
                                    gymStore.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: newR)
                                }
                            ),
                            isCompleted: set.isCompleted,
                            unit: gymStore.settings.weightUnit,
                            onToggleComplete: {
                                gymStore.toggleSetCompleted(exerciseIndex: exerciseIndex, setIndex: setIndex)
                            },
                            onDelete: {
                                gymStore.removeSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
                            }
                        )
                    }
                }
                
                // + Add Set Button
                Button {
                    gymStore.addSet(to: exerciseIndex)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline)
                        Text("Add Set")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemFill))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}
