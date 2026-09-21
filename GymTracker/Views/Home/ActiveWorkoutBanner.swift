import SwiftUI

public struct ActiveWorkoutBanner: View {
    let workout: Workout
    let onResume: () -> Void
    let onDiscard: () -> Void
    
    @State private var isShowingDiscardAlert: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("WORKOUT IN PROGRESS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
                
                Spacer()
                
                Button(role: .destructive) {
                    isShowingDiscardAlert = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("\(workout.exercises.count) exercises • Started \(workout.startTime ?? workout.date, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    onResume()
                    HapticFeedback.medium()
                } label: {
                    HStack(spacing: 6) {
                        Text("Resume")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
        )
        .alert("Discard Workout?", isPresented: $isShowingDiscardAlert) {
            Button("Discard", role: .destructive) {
                onDiscard()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to discard your ongoing workout?")
        }
    }
}
