import SwiftUI

public struct SetRowView: View {
    let setNumber: Int
    let previousString: String
    @Binding var weight: Double
    @Binding var reps: Int
    let isCompleted: Bool
    let unit: WeightUnit
    let onToggleComplete: () -> Void
    let onDelete: () -> Void
    
    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isRepsFocused: Bool
    
    public init(
        setNumber: Int,
        previousString: String,
        weight: Binding<Double>,
        reps: Binding<Int>,
        isCompleted: Bool,
        unit: WeightUnit,
        onToggleComplete: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self.previousString = previousString
        self._weight = weight
        self._reps = reps
        self.isCompleted = isCompleted
        self.unit = unit
        self.onToggleComplete = onToggleComplete
        self.onDelete = onDelete
    }
    
    private func formatNumberForDisplay(_ value: Double) -> String {
        if value == 0 { return "" }
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.2f", value).replacingOccurrences(of: ".00", with: "").replacingOccurrences(of: "0$", with: "", options: .regularExpression)
        }
    }
    
    private func parseDecimal(_ text: String) -> Double {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0.0
    }
    
    private func checkAutoStartRestTimer() {
        if GymStore.shared.settings.autoStartRestTimer && weight > 0 {
            RestTimerManager.shared.start(duration: GymStore.shared.settings.defaultRestDuration)
            HapticFeedback.light()
        }
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Set Number
            Text("\(setNumber)")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .center)
            
            // Previous Record String
            Text(previousString)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Weight Input (supports decimals: 12.5 or 12,5)
            TextField(weight == 0 ? "0" : formatNumberForDisplay(weight), text: $weightText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(width: 72)
                .focused($isWeightFocused)
                .onChange(of: weightText) { _, newValue in
                    let val = parseDecimal(newValue)
                    if val != weight {
                        weight = val
                    }
                }
                .onChange(of: isWeightFocused) { wasFocused, isFocused in
                    if wasFocused && !isFocused {
                        // When finishing typing weight, normalize format and start 2 min timer
                        if weight > 0 {
                            weightText = formatNumberForDisplay(weight)
                            checkAutoStartRestTimer()
                        } else {
                            weightText = ""
                        }
                    }
                }
            
            // Reps Input
            TextField(reps == 0 ? "0" : "\(reps)", text: $repsText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(width: 60)
                .focused($isRepsFocused)
                .onChange(of: repsText) { _, newValue in
                    let val = Int(newValue.filter { "0123456789".contains($0) }) ?? 0
                    if val != reps {
                        reps = val
                    }
                }
                .onChange(of: isRepsFocused) { wasFocused, isFocused in
                    if wasFocused && !isFocused {
                        if reps > 0 {
                            repsText = "\(reps)"
                            checkAutoStartRestTimer()
                        } else {
                            repsText = ""
                        }
                    }
                }
            
            // Complete Checkmark Button (Optional visual check)
            Button {
                isWeightFocused = false
                isRepsFocused = false
                onToggleComplete()
            } label: {
                ZStack {
                    let hasData = isCompleted || weight > 0 || reps > 0
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(hasData ? Color.green : Color(.tertiarySystemFill))
                        .frame(width: 44, height: 34)
                    
                    Image(systemName: "checkmark")
                        .font(.system(.subheadline, weight: .bold))
                        .foregroundStyle(hasData ? .white : Color(.quaternaryLabel))
                }
            }
            .buttonStyle(.plain)
            .frame(width: 44)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background((isCompleted || weight > 0 || reps > 0) ? Color.green.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onAppear {
            if weight > 0 {
                weightText = formatNumberForDisplay(weight)
            }
            if reps > 0 {
                repsText = "\(reps)"
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
