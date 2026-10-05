import SwiftUI

public struct ActiveWorkoutView: View {
    @ObservedObject var gymStore = GymStore.shared
    @State private var isShowingExercisePicker: Bool = false
    @State private var isShowingClearAlert: Bool = false
    @State private var isShowingRenameSheet: Bool = false
    
    private var workout: Workout {
        gymStore.activeWorkout ?? Workout(name: "Treino de Hoje", date: Date(), exercises: [])
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Card (Name, Date, Notes, Quick Presets)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center) {
                                Button {
                                    isShowingRenameSheet = true
                                    HapticFeedback.selection()
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(workout.name)
                                            .font(.system(.title2, design: .rounded, weight: .bold))
                                            .foregroundStyle(.primary)
                                        
                                        Image(systemName: "pencil")
                                            .font(.caption.bold())
                                            .foregroundStyle(.secondary)
                                            .padding(6)
                                            .background(Color(.tertiarySystemFill))
                                            .clipShape(Circle())
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                                
                                if let dominant = workout.dominantMuscleGroup {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(dominant.themeColor)
                                            .frame(width: 8, height: 8)
                                        Text(dominant.shortPortugueseName)
                                            .font(.caption2.bold())
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(dominant.themeColor.opacity(0.15))
                                    .foregroundStyle(dominant.themeColor)
                                    .clipShape(Capsule())
                                } else {
                                    // Date Badge
                                    Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(Capsule())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Quick Presets Bar
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(["Push", "Pull", "Legs", "Superior", "Inferior", "Peito", "Costas", "Pernas", "Ombros", "Full Body"], id: \.self) { preset in
                                        Button {
                                            gymStore.updateWorkoutName(name: preset)
                                            HapticFeedback.selection()
                                        } label: {
                                            Text(preset)
                                                .font(.caption2.bold())
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 5)
                                                .background(workout.name == preset ? Color.accentColor : Color(.tertiarySystemFill))
                                                .foregroundStyle(workout.name == preset ? .white : .primary)
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                            // General Notes
                            TextField("Notas do treino de hoje (opcional)...", text: Binding(
                                get: { workout.notes ?? "" },
                                set: { gymStore.updateWorkoutNotes(notes: $0) }
                            ))
                            .font(.footnote)
                            .padding(8)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Exercises List
                        if workout.exercises.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary.opacity(0.6))
                                
                                Text("Caderno de Treino Aberto")
                                    .font(.headline)
                                
                                Text("Toca no botão abaixo para adicionar exercícios e começar a registar.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button {
                                    isShowingExercisePicker = true
                                    HapticFeedback.light()
                                } label: {
                                    Label("Adicionar Exercício", systemImage: "plus.circle.fill")
                                        .font(.headline)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 14)
                                        .background(Color.accentColor)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 3)
                                }
                            }
                            .padding(.vertical, 50)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { (index, _) in
                                    WorkoutExerciseCard(
                                        exerciseIndex: index,
                                        onRemove: {
                                            gymStore.removeExerciseFromActiveWorkout(at: index)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Bottom Actions
                        VStack(spacing: 12) {
                            Button {
                                isShowingExercisePicker = true
                                HapticFeedback.light()
                            } label: {
                                Label("Adicionar Exercício", systemImage: "plus.circle.fill")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            if !workout.exercises.isEmpty {
                                Button(role: .destructive) {
                                    isShowingClearAlert = true
                                } label: {
                                    Text("Limpar Treino de Hoje")
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                        .padding(.vertical, 6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 80)
                    }
                }
                
                // Floating Rest Timer
                RestTimerOverlay()
            }
            .navigationTitle("Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isShowingExercisePicker = true
                        } label: {
                            Label("Adicionar Exercício", systemImage: "plus")
                        }
                        
                        Button {
                            isShowingRenameSheet = true
                        } label: {
                            Label("Renomear Treino", systemImage: "pencil")
                        }
                        
                        if !workout.exercises.isEmpty {
                            Button(role: .destructive) {
                                isShowingClearAlert = true
                            } label: {
                                Label("Limpar Treino de Hoje", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                    }
                }
            }
            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerSheet { selectedExercise in
                    gymStore.addExerciseToActiveWorkout(selectedExercise)
                }
            }
            .sheet(isPresented: $isShowingRenameSheet) {
                RenameWorkoutSheet(workout: workout) { newName in
                    gymStore.updateWorkoutName(name: newName)
                }
            }
            .alert("Limpar Treino de Hoje?", isPresented: $isShowingClearAlert) {
                Button("Limpar", role: .destructive) {
                    gymStore.clearTodayWorkout()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Isto vai esvaziar a folha de treino de hoje.")
            }
        }
    }
}
