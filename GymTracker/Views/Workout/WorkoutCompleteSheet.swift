import SwiftUI

public struct WorkoutCompleteSheet: View {
    let workout: Workout
    let unit: WeightUnit
    let onDismiss: () -> Void
    
    public var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Celebration icon & header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                }
                
                Text("Workout Complete! 🎉")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(workout.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                QuickStatCard(
                    title: "Data",
                    value: workout.date.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar",
                    iconColor: .blue
                )
                
                QuickStatCard(
                    title: "Exercises",
                    value: "\(workout.totalExercisesCount)",
                    icon: "figure.strengthtraining.traditional",
                    iconColor: .orange
                )
                
                QuickStatCard(
                    title: "Sets Completed",
                    value: "\(workout.totalCompletedSets)",
                    icon: "repeat",
                    iconColor: .teal
                )
                
                QuickStatCard(
                    title: "Total Volume",
                    value: WorkoutCalculations.formatVolume(workout.totalVolume, unit: unit),
                    icon: "scalemass.fill",
                    iconColor: .purple
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Done Button
            Button {
                onDismiss()
                HapticFeedback.light()
            } label: {
                Text("Done")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.fraction(0.75)])
        .presentationDragIndicator(.visible)
    }
}
