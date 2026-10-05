import SwiftUI

public struct WorkoutHistoryCard: View {
    @ObservedObject var gymStore = GymStore.shared
    let workout: Workout
    let onRenameTapped: () -> Void
    
    private var dominantMuscle: MuscleGroup? {
        workout.dominantMuscleGroup
    }
    
    private var dominantColor: Color {
        workout.dominantMuscleColor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // Dominant Muscle Color Accent Bar on the left
            RoundedRectangle(cornerRadius: 3)
                .fill(dominantColor)
                .frame(width: 5)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                // Top: Name, Rename button, Date & Exercises count
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(workout.name)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Button {
                                onRenameTapped()
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.secondary)
                                    .padding(4)
                                    .background(Color(.tertiarySystemFill))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            if Calendar.current.isDateInToday(workout.date) {
                                Text("Hoje")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundStyle(.green)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Dominant Muscle Badge
                    if let dominant = dominantMuscle {
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
                        Text("\(workout.exercises.count) ex.")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Muscle Breakdown Pills (Shows which muscles were trained and series count)
                if !workout.muscleBreakdown.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(workout.muscleBreakdown) { item in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(item.muscle.themeColor)
                                        .frame(width: 6, height: 6)
                                    Text("\(item.muscle.shortPortugueseName) (\(item.setCount))")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                // Exercises snippet
                if !workout.exercises.isEmpty {
                    Text(workout.exercises.map(\.exerciseName).joined(separator: " • "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Bottom metrics: Completed sets & Volume
                HStack {
                    Text("\(workout.totalCompletedSets) séries")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    Text(WorkoutCalculations.formatVolume(workout.totalVolume, unit: gymStore.settings.weightUnit))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 4)
        }
    }
}
