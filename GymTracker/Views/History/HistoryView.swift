import SwiftUI

public enum HistorySection: String, CaseIterable {
    case workouts = "Treinos"
    case exercises = "Exercícios"
}

public enum WorkoutDisplayMode: String, CaseIterable {
    case list = "Lista"
    case calendar = "Calendário"
}

public struct HistoryView: View {
    @ObservedObject var gymStore = GymStore.shared
    @State private var selectedSection: HistorySection = .workouts
    @State private var workoutDisplayMode: WorkoutDisplayMode = .list
    @State private var searchText: String = ""
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var workoutToRename: Workout? = nil
    
    private var daysWithWorkouts: [Workout] {
        gymStore.workouts.filter { !$0.exercises.isEmpty }
    }
    
    private var filteredWorkouts: [Workout] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return daysWithWorkouts
        }
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        return daysWithWorkouts.filter {
            $0.name.lowercased().contains(query) ||
            $0.exercises.contains(where: { $0.exerciseName.lowercased().contains(query) }) ||
            ($0.dominantMuscleGroup?.shortPortugueseName.lowercased().contains(query) ?? false)
        }
    }
    
    private var filteredExercises: [Exercise] {
        var list = gymStore.exercises
        
        if let muscle = selectedMuscleGroup {
            list = list.filter { $0.muscleGroup == muscle }
        }
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
            list = list.filter { $0.name.lowercased().contains(query) }
        }
        
        // Sort: exercises with logged sessions first, then alphabetically
        return list.sorted { ex1, ex2 in
            let pr1 = WorkoutCalculations.calculatePRs(for: ex1.id, in: gymStore.workouts)
            let pr2 = WorkoutCalculations.calculatePRs(for: ex2.id, in: gymStore.workouts)
            if pr1.totalSessions != pr2.totalSessions {
                return pr1.totalSessions > pr2.totalSessions
            }
            return ex1.name < ex2.name
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Primary Section Picker: Treinos vs Exercícios
                Picker("Vista do Histórico", selection: $selectedSection) {
                    ForEach(HistorySection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                if selectedSection == .workouts {
                    // Secondary View Mode: Lista vs Calendário
                    Picker("Modo de Visualização", selection: $workoutDisplayMode) {
                        ForEach(WorkoutDisplayMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode == .list ? "list.bullet" : "calendar")
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
                    
                    if workoutDisplayMode == .calendar {
                        // MARK: - Calendar View
                        WorkoutCalendarView()
                    } else {
                        // MARK: - Workouts List View
                        if daysWithWorkouts.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 56))
                                    .foregroundStyle(.secondary)
                                
                                Text("Sem Histórico de Treinos")
                                    .font(.title2.bold())
                                
                                Text("Os treinos que apontares na aba Treino ficam automaticamente arquivados aqui por dia.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List {
                                ForEach(filteredWorkouts) { workout in
                                    NavigationLink {
                                        WorkoutDetailView(workout: workout)
                                    } label: {
                                        WorkoutHistoryCard(
                                            workout: workout,
                                            onRenameTapped: {
                                                workoutToRename = workout
                                            }
                                        )
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            gymStore.deleteWorkoutFromHistory(workout)
                                        } label: {
                                            Label("Apagar", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            workoutToRename = workout
                                        } label: {
                                            Label("Renomear", systemImage: "pencil")
                                        }
                                        .tint(.orange)
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                } else {
                    // MARK: - Exercises Evolution Directory
                    VStack(spacing: 0) {
                        // Muscle Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button {
                                    selectedMuscleGroup = nil
                                    HapticFeedback.selection()
                                } label: {
                                    Text("Todos")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(selectedMuscleGroup == nil ? Color.primary : Color(.tertiarySystemFill))
                                        .foregroundStyle(selectedMuscleGroup == nil ? Color(.systemBackground) : Color.primary)
                                        .clipShape(Capsule())
                                }
                                
                                ForEach(MuscleGroup.allCases) { muscle in
                                    Button {
                                        if selectedMuscleGroup == muscle {
                                            selectedMuscleGroup = nil
                                        } else {
                                            selectedMuscleGroup = muscle
                                        }
                                        HapticFeedback.selection()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: muscle.iconName)
                                            Text(muscle.shortPortugueseName)
                                        }
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(selectedMuscleGroup == muscle ? muscle.themeColor : Color(.tertiarySystemFill))
                                        .foregroundStyle(selectedMuscleGroup == muscle ? .white : .primary)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        
                        List {
                            ForEach(filteredExercises) { exercise in
                                let prs = WorkoutCalculations.calculatePRs(for: exercise.id, in: gymStore.workouts)
                                let points = WorkoutCalculations.progressPoints(for: exercise.id, in: gymStore.workouts)
                                
                                NavigationLink {
                                    ExerciseDetailView(exercise: exercise)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: exercise.muscleGroup.iconName)
                                            .font(.headline)
                                            .foregroundStyle(exercise.muscleGroup.themeColor)
                                            .frame(width: 36, height: 36)
                                            .background(exercise.muscleGroup.themeColor.opacity(0.12))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text(exercise.name)
                                                    .font(.system(.body, design: .rounded, weight: .bold))
                                                    .foregroundStyle(.primary)
                                                
                                                if exercise.isCustom {
                                                    Text("Custom")
                                                        .font(.caption2.bold())
                                                        .foregroundStyle(.orange)
                                                }
                                            }
                                            
                                            if prs.totalSessions > 0 {
                                                HStack(spacing: 8) {
                                                    Text("PR: \(WorkoutCalculations.formatWeight(prs.bestWeight, unit: gymStore.settings.weightUnit))")
                                                        .font(.caption.bold())
                                                        .foregroundStyle(.primary)
                                                    
                                                    Text("•")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Text("\(prs.totalSessions) \(prs.totalSessions == 1 ? "sessão" : "sessões")")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            } else {
                                                Text("Sem treinos registados ainda")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if points.count >= 2 {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.accentColor)
                                                .padding(6)
                                                .background(Color.accentColor.opacity(0.1))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Histórico")
            .searchable(text: $searchText, prompt: selectedSection == .workouts ? "Pesquisar treinos ou exercícios..." : "Pesquisar evolução de exercícios...")
            .sheet(item: $workoutToRename) { workout in
                RenameWorkoutSheet(workout: workout) { newName in
                    gymStore.renameWorkout(id: workout.id, newName: newName)
                }
            }
        }
    }
}
