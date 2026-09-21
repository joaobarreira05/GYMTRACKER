import SwiftUI

public struct CreateTemplateSheet: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName: String = ""
    @State private var templateNotes: String = ""
    @State private var selectedExerciseIds: [UUID] = []
    @State private var isShowingExercisePicker: Bool = false
    
    private var selectedExercises: [Exercise] {
        selectedExerciseIds.compactMap { id in
            gymStore.exercises.first(where: { $0.id == id })
        }
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Template Info") {
                    TextField("Template Name (e.g. Push Heavy)", text: $templateName)
                    TextField("Notes (optional)", text: $templateNotes)
                }
                
                Section("Exercises") {
                    if selectedExercises.isEmpty {
                        Text("No exercises added yet. Tap Add Exercise below.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(selectedExercises) { exercise in
                            HStack(spacing: 12) {
                                Image(systemName: exercise.muscleGroup.iconName)
                                    .foregroundStyle(exercise.muscleGroup.themeColor)
                                Text(exercise.name)
                                    .font(.body)
                                Spacer()
                            }
                        }
                        .onDelete { indexSet in
                            selectedExerciseIds.remove(atOffsets: indexSet)
                        }
                        .onMove { indices, newOffset in
                            selectedExerciseIds.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                            .font(.subheadline.bold())
                    }
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        
                        let newTemplate = WorkoutTemplate(
                            name: trimmed,
                            notes: templateNotes.isEmpty ? nil : templateNotes,
                            exerciseIds: selectedExerciseIds,
                            isCustom: true
                        )
                        gymStore.saveTemplate(newTemplate)
                        dismiss()
                        HapticFeedback.success()
                    }
                    .disabled(templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerSheet { exercise in
                    if !selectedExerciseIds.contains(exercise.id) {
                        selectedExerciseIds.append(exercise.id)
                    }
                }
            }
        }
    }
}
