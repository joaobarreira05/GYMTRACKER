import SwiftUI

public struct RenameWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    let workout: Workout
    let onSave: (String) -> Void
    
    @State private var name: String
    @FocusState private var isFocused: Bool
    
    private let presetOptions = [
        "Push", "Pull", "Legs", "Superior", "Inferior",
        "Peito", "Costas", "Pernas", "Ombros", "Braços", "Full Body", "Core"
    ]
    
    public init(workout: Workout, onSave: @escaping (String) -> Void) {
        self.workout = workout
        self.onSave = onSave
        self._name = State(initialValue: workout.name)
    }
    
    private var autoSuggestedName: String? {
        if let dominant = workout.dominantMuscleGroup {
            let topMuscles = workout.muscleBreakdown.prefix(2).map(\.muscle.shortPortugueseName).joined(separator: " & ")
            return topMuscles
        }
        return nil
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Nome do Treino") {
                    HStack {
                        TextField("Ex: Push, Costas e Bíceps...", text: $name)
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .focused($isFocused)
                        
                        if !name.isEmpty {
                            Button {
                                name = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                if let suggested = autoSuggestedName, suggested.lowercased() != name.lowercased() {
                    Section("Sugestão Baseada nos Exercícios") {
                        Button {
                            name = suggested
                            HapticFeedback.selection()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.orange)
                                Text("Usar \"\(suggested)\"")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let dom = workout.dominantMuscleGroup {
                                    Text(dom.shortPortugueseName)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(dom.themeColor.opacity(0.15))
                                        .foregroundStyle(dom.themeColor)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                Section("Atalhos Rápidos") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 85))], spacing: 8) {
                        ForEach(presetOptions, id: \.self) { preset in
                            Button {
                                name = preset
                                HapticFeedback.selection()
                            } label: {
                                Text(preset)
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(name == preset ? Color.accentColor : Color(.tertiarySystemFill))
                                    .foregroundStyle(name == preset ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Renomear Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                            dismiss()
                            HapticFeedback.success()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}
