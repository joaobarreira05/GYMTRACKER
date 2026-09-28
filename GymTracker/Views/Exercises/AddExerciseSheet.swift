import SwiftUI

public struct AddExerciseSheet: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var selectedMuscleGroup: MuscleGroup
    @FocusState private var isNameFocused: Bool
    
    var onCreated: ((Exercise) -> Void)? = nil
    
    public init(
        initialName: String = "",
        initialMuscleGroup: MuscleGroup? = nil,
        onCreated: ((Exercise) -> Void)? = nil
    ) {
        self._name = State(initialValue: initialName)
        self._selectedMuscleGroup = State(initialValue: initialMuscleGroup ?? .chest)
        self.onCreated = onCreated
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name (e.g. Incline Smith Press)", text: $name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)
                    
                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases) { muscle in
                            HStack {
                                Image(systemName: muscle.iconName)
                                Text(muscle.rawValue)
                            }
                            .tag(muscle)
                        }
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            gymStore.addCustomExercise(name: trimmed, muscleGroup: selectedMuscleGroup)
                            if let created = gymStore.exercises.first(where: { $0.name == trimmed }) {
                                onCreated?(created)
                            }
                            dismiss()
                            HapticFeedback.success()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
