import SwiftUI

public struct ExerciseListView: View {
    @ObservedObject var gymStore = GymStore.shared
    @State private var searchText: String = ""
    @State private var selectedMuscleGroup: MuscleGroup? = nil
    @State private var isShowingAddExerciseSheet: Bool = false
    
    private var filteredExercises: [Exercise] {
        var list = gymStore.exercises
        
        if let muscle = selectedMuscleGroup {
            list = list.filter { $0.muscleGroup == muscle }
        }
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
            list = list.filter { $0.name.lowercased().contains(query) }
        }
        
        return list
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedMuscleGroup = nil
                            HapticFeedback.selection()
                        } label: {
                            Text("All")
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
                                    Text(muscle.shortName)
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
                    .padding(.vertical, 10)
                }
                
                // Exercise List
                List {
                    ForEach(filteredExercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: exercise.muscleGroup.iconName)
                                    .font(.headline)
                                    .foregroundStyle(exercise.muscleGroup.themeColor)
                                    .frame(width: 32, height: 32)
                                    .background(exercise.muscleGroup.themeColor.opacity(0.12))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                        .foregroundStyle(.primary)
                                    
                                    HStack(spacing: 6) {
                                        Text(exercise.muscleGroup.rawValue)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        
                                        if exercise.isCustom {
                                            Text("Custom")
                                                .font(.caption2.bold())
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Exercises")
            .searchable(text: $searchText, prompt: "Search exercises...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddExerciseSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddExerciseSheet) {
                AddExerciseSheet()
            }
        }
    }
}
