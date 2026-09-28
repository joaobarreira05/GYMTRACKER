import SwiftUI
import Charts

public enum ProgressMetric: String, CaseIterable, Identifiable {
    case maxWeight = "Carga Máxima"
    case est1RM = "1RM Estimado"
    case volume = "Volume Total"
    case reps = "Melhores Reps"
    
    public var id: String { rawValue }
    
    public var shortTitle: String {
        switch self {
        case .maxWeight: return "Carga"
        case .est1RM: return "1RM"
        case .volume: return "Volume"
        case .reps: return "Reps"
        }
    }
}

public struct ExerciseDetailView: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    
    @State private var selectedMetric: ProgressMetric = .maxWeight
    @State private var isShowingDeleteAlert: Bool = false
    
    public init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    private var prs: PersonalRecords {
        WorkoutCalculations.calculatePRs(for: exercise.id, in: gymStore.workouts)
    }
    
    private var progressPoints: [ExerciseProgressPoint] {
        WorkoutCalculations.progressPoints(for: exercise.id, in: gymStore.workouts)
    }
    
    private var historicalSessions: [(workout: Workout, exercise: WorkoutExercise)] {
        WorkoutCalculations.sessions(for: exercise.id, in: gymStore.workouts)
    }
    
    private func metricValue(for point: ExerciseProgressPoint) -> Double {
        switch selectedMetric {
        case .maxWeight: return point.maxWeight
        case .est1RM: return point.estimated1RM
        case .volume: return point.totalVolume
        case .reps: return Double(point.bestReps)
        }
    }
    
    private func formatMetricValue(_ val: Double) -> String {
        switch selectedMetric {
        case .maxWeight, .est1RM:
            return WorkoutCalculations.formatWeight(val, unit: gymStore.settings.weightUnit)
        case .volume:
            return WorkoutCalculations.formatVolume(val, unit: gymStore.settings.weightUnit)
        case .reps:
            return "\(Int(val)) reps"
        }
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
                    Text("Recordes Pessoais (PRs)")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickStatCard(
                            title: "Melhor Carga",
                            value: prs.bestWeight > 0 ? WorkoutCalculations.formatWeight(prs.bestWeight, unit: gymStore.settings.weightUnit) : "—",
                            icon: "trophy.fill",
                            iconColor: .yellow
                        )
                        
                        QuickStatCard(
                            title: "1RM Estimado",
                            value: prs.best1RM > 0 ? WorkoutCalculations.formatWeight(prs.best1RM, unit: gymStore.settings.weightUnit) : "—",
                            icon: "bolt.shield.fill",
                            iconColor: .purple
                        )
                        
                        QuickStatCard(
                            title: "Melhor Volume",
                            value: prs.bestVolume > 0 ? WorkoutCalculations.formatVolume(prs.bestVolume, unit: gymStore.settings.weightUnit) : "—",
                            icon: "scalemass.fill",
                            iconColor: .indigo
                        )
                        
                        QuickStatCard(
                            title: "Total Sessões",
                            value: "\(prs.totalSessions)",
                            icon: "calendar",
                            iconColor: .blue
                        )
                    }
                    .padding(.horizontal, 16)
                }
                
                // MARK: - Progress Over Time Chart
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Gráfico de Evolução")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Metric Picker
                        Picker("Métrica", selection: $selectedMetric) {
                            ForEach(ProgressMetric.allCases) { metric in
                                Text(metric.shortTitle).tag(metric)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 220)
                    }
                    .padding(.horizontal, 16)
                    
                    if progressPoints.count >= 2 {
                        VStack(alignment: .leading, spacing: 14) {
                            Chart {
                                ForEach(progressPoints) { point in
                                    let val = metricValue(for: point)
                                    AreaMark(
                                        x: .value("Data", point.date),
                                        y: .value(selectedMetric.rawValue, val)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.accentColor.opacity(0.32), Color.accentColor.opacity(0.02)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    
                                    LineMark(
                                        x: .value("Data", point.date),
                                        y: .value(selectedMetric.rawValue, val)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.accentColor)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    PointMark(
                                        x: .value("Data", point.date),
                                        y: .value(selectedMetric.rawValue, val)
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
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            
                            // Progression text summary
                            if let first = progressPoints.first, let last = progressPoints.last {
                                let firstVal = metricValue(for: first)
                                let lastVal = metricValue(for: last)
                                let diff = lastVal - firstVal
                                let pct = firstVal > 0 ? (diff / firstVal) * 100 : 0
                                
                                HStack(spacing: 8) {
                                    Text("Evolução Global:")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("\(formatMetricValue(firstVal)) → \(formatMetricValue(lastVal))")
                                        .font(.caption.bold())
                                    
                                    if diff != 0 {
                                        Text("(\(diff > 0 ? "+" : "")\(formatMetricValue(diff)), \(String(format: "%+.1f%%", pct)))")
                                            .font(.caption.bold())
                                            .foregroundStyle(diff > 0 ? .green : .red)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 16)
                    } else if progressPoints.count == 1, let singlePoint = progressPoints.first {
                        let singleVal = metricValue(for: singlePoint)
                        VStack(spacing: 12) {
                            Chart {
                                PointMark(
                                    x: .value("Data", singlePoint.date),
                                    y: .value(selectedMetric.rawValue, singleVal)
                                )
                                .foregroundStyle(Color.accentColor)
                                .symbolSize(70)
                            }
                            .frame(height: 120)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.orange)
                                Text("1ª Sessão: \(formatMetricValue(singleVal)). Adiciona mais um treino com este exercício para ver a curva completa!")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
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
                            Text("Ainda sem registos suficientes para gerar gráfico.")
                                .font(.subheadline.bold())
                            Text("Regista este exercício num treino para começar a ver a evolução.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                    }
                }
                
                // MARK: - Exercise History List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Histórico de Sessões")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    
                    if historicalSessions.isEmpty {
                        Text("Ainda não completaste nenhum treino com este exercício.")
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
                                        ForEach(session.exercise.sets.filter { $0.isCompleted || $0.weight > 0 || $0.reps > 0 }) { set in
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
                        Label("Eliminar Exercício Personalizado", systemImage: "trash")
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
        .alert("Eliminar Exercício?", isPresented: $isShowingDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                gymStore.deleteCustomExercise(exercise)
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Tens a certeza que queres eliminar este exercício personalizado?")
        }
    }
}
