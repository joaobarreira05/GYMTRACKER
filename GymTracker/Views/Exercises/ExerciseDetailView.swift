import SwiftUI
import Charts

public struct ExerciseDetailView: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    
    @State private var isShowingDeleteAlert: Bool = false
    
    private var prs: PersonalRecords {
        WorkoutCalculations.calculatePRs(for: exercise.id, in: gymStore.workouts)
    }
    
    private var progressPoints: [ExerciseProgressPoint] {
        WorkoutCalculations.progressPoints(for: exercise.id, in: gymStore.workouts)
    }
    
    private var historicalSessions: [(workout: Workout, exercise: WorkoutExercise)] {
        WorkoutCalculations.sessions(for: exercise.id, in: gymStore.workouts)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Badge & Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(exercise.muscleGroup.rawValue, systemImage: exercise.muscleGroup.iconName)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(exercise.muscleGroup.themeColor.opacity(0.15))
                            .foregroundStyle(exercise.muscleGroup.themeColor)
                            .clipShape(Capsule())
                        
                        if exercise.isCustom {
                            Text("Custom")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                    }
                    
                    Text(exercise.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                // MARK: - Personal Records (PRs)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Personal Records")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickStatCard(
                            title: "Best Weight",
                            value: prs.bestWeight > 0 ? WorkoutCalculations.formatWeight(prs.bestWeight, unit: gymStore.settings.weightUnit) : "—",
                            icon: "trophy.fill",
                            iconColor: .yellow
                        )
                        
                        QuickStatCard(
                            title: "Best Reps",
                            value: prs.bestReps > 0 ? "\(prs.bestReps) reps" : "—",
                            icon: "flame.fill",
                            iconColor: .orange
                        )
                        
                        QuickStatCard(
                            title: "Best Volume",
                            value: prs.bestVolume > 0 ? WorkoutCalculations.formatVolume(prs.bestVolume, unit: gymStore.settings.weightUnit) : "—",
                            icon: "scalemass.fill",
                            iconColor: .purple
                        )
                        
                        QuickStatCard(
                            title: "Total Sessions",
                            value: "\(prs.totalSessions)",
                            icon: "calendar",
                            iconColor: .blue
                        )
                    }
                    .padding(.horizontal, 16)
                }
                
                // MARK: - Weight Progress Chart
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weight Progress")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    if progressPoints.count >= 2 {
                        VStack(alignment: .leading, spacing: 12) {
                            Chart {
                                ForEach(progressPoints) { point in
                                    LineMark(
                                        x: .value("Date", point.date),
                                        y: .value("Weight", point.maxWeight)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.accentColor)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    PointMark(
                                        x: .value("Date", point.date),
                                        y: .value("Weight", point.maxWeight)
                                    )
                                    .foregroundStyle(Color.accentColor)
                                    .symbolSize(36)
                                }
                            }
                            .frame(height: 190)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            
                            // Progression text summary
                            if let first = progressPoints.first, let last = progressPoints.last {
                                let diff = last.maxWeight - first.maxWeight
                                HStack {
                                    Text("Progress:")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(WorkoutCalculations.formatWeight(first.maxWeight, unit: gymStore.settings.weightUnit)) → \(WorkoutCalculations.formatWeight(last.maxWeight, unit: gymStore.settings.weightUnit))")
                                        .font(.caption.bold())
                                    if diff > 0 {
                                        Text("(+\(WorkoutCalculations.formatWeight(diff, unit: gymStore.settings.weightUnit)))")
                                            .font(.caption.bold())
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Need at least 2 sessions to display progress graph.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                    }
                }
                
                // MARK: - Exercise History List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercise History")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    if historicalSessions.isEmpty {
                        Text("No completed workouts with this exercise yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(historicalSessions, id: \.workout.id) { session in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(session.workout.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        Text(session.workout.name)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    // Sets summary
                                    HStack(spacing: 8) {
                                        ForEach(session.exercise.sets.filter { $0.isCompleted }) { set in
                                            Text("\(WorkoutCalculations.formatWeight(set.weight, unit: gymStore.settings.weightUnit)) × \(set.reps)")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(.tertiarySystemFill))
                                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                        }
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // Delete custom exercise button
                if exercise.isCustom {
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Delete Custom Exercise", systemImage: "trash")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .padding(.bottom, 24)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Exercise?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                gymStore.deleteCustomExercise(exercise)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this custom exercise?")
        }
    }
}
