import SwiftUI

public struct WorkoutDetailView: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    let workoutId: UUID
    
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isShowingEditSheet: Bool = false
    
    public init(workout: Workout) {
        self.workoutId = workout.id
    }
    
    private var currentWorkout: Workout? {
        gymStore.workouts.first(where: { $0.id == workoutId })
    }
    
    public var body: some View {
        Group {
            if let workout = currentWorkout {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Top Summary Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name)
                                        .font(.system(.title2, design: .rounded, weight: .bold))
                                    
                                    Text(workout.date.formatted(date: .long, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            if let notes = workout.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            
                            Divider()
                            
                            // Key metrics
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("EXERCÍCIOS")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.secondary)
                                    Text("\(workout.exercises.count)")
                                        .font(.subheadline.bold())
                                }
                                
                                Divider().frame(height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("VOLUME")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.secondary)
                                    Text(WorkoutCalculations.formatVolume(workout.totalVolume, unit: gymStore.settings.weightUnit))
                                        .font(.subheadline.bold())
                                }
                                
                                Divider().frame(height: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SETS")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.secondary)
                                    Text("\(workout.totalCompletedSets)")
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)
                        
                        // Copy to Today Action Button
                        Button {
                            gymStore.copyWorkoutToToday(workout)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.subheadline)
                                Text("Copy to Today (Repetir Hoje)")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.25), radius: 8, y: 3)
                        }
                        .padding(.horizontal, 16)
                        
                        // Exercises List
                        VStack(spacing: 14) {
                            ForEach(workout.exercises) { ex in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(ex.exerciseName)
                                                .font(.system(.headline, design: .rounded, weight: .bold))
                                            
                                            Text(ex.muscleGroup.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(ex.muscleGroup.themeColor)
                                        }
                                        Spacer()
                                        Text("\(ex.completedSetsCount) sets")
                                            .font(.caption.bold())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if let notes = ex.notes, !notes.isEmpty {
                                        HStack(alignment: .top, spacing: 6) {
                                            Image(systemName: "note.text")
                                                .font(.caption)
                                                .foregroundStyle(Color.accentColor)
                                            Text(notes)
                                                .font(.caption)
                                                .foregroundStyle(.primary)
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    }
                                    
                                    // Sets Table - Show all recorded sets
                                    let recordedSets = ex.sets.filter { $0.isCompleted || $0.weight > 0 || $0.reps > 0 }
                                    VStack(spacing: 6) {
                                        ForEach(recordedSets.isEmpty ? ex.sets : recordedSets) { set in
                                            HStack {
                                                Text("Set \(set.setNumber)")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.secondary)
                                                    .frame(width: 50, alignment: .leading)
                                                
                                                Spacer()
                                                
                                                Text("\(WorkoutCalculations.formatWeight(set.weight, unit: gymStore.settings.weightUnit)) × \(set.reps) reps")
                                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                                
                                                Spacer()
                                                
                                                Text(WorkoutCalculations.formatVolume(set.volume, unit: gymStore.settings.weightUnit))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .frame(width: 80, alignment: .trailing)
                                            }
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(Color(.tertiarySystemFill))
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        }
                                    }
                                }
                                .padding(14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Action Buttons: Edit & Delete
                        HStack(spacing: 12) {
                            Button {
                                isShowingEditSheet = true
                            } label: {
                                Label("Edit Workout", systemImage: "pencil")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            Button(role: .destructive) {
                                isShowingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .foregroundStyle(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
                .navigationTitle(workout.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingEditSheet = true
                        } label: {
                            Text("Edit")
                                .font(.headline)
                        }
                    }
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    EditWorkoutView(workout: workout)
                }
                .alert("Delete Workout?", isPresented: $isShowingDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        gymStore.deleteWorkoutFromHistory(workout)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This workout record will be permanently deleted.")
                }
            } else {
                Text("Workout not found")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
