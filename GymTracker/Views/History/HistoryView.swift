import SwiftUI

public struct HistoryView: View {
    @ObservedObject var gymStore = GymStore.shared
    @State private var searchText: String = ""
    
    private var daysWithWorkouts: [Workout] {
        gymStore.workouts.filter { !$0.exercises.isEmpty }
    }
    
    private var filteredWorkouts: [Workout] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return daysWithWorkouts
        }
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        return daysWithWorkouts.filter {
            $0.name.lowercased().contains(query) ||
            $0.exercises.contains(where: { $0.exerciseName.lowercased().contains(query) })
        }
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if daysWithWorkouts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 56))
                            .foregroundStyle(.secondary)
                        
                        Text("Sem Histórico de Treinos")
                            .font(.title2.bold())
                        
                        Text("Os treinos que apontares na aba Treino ficam automaticamente arquivados aqui por dia.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text(workout.name)
                                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                                    .foregroundStyle(.primary)
                                                
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
                                        
                                        Text("\(workout.exercises.count) ex.")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(.tertiarySystemFill))
                                            .clipShape(Capsule())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    // Exercises list snippet
                                    Text(workout.exercises.map(\.exerciseName).joined(separator: " • "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    
                                    HStack {
                                        Text("\(workout.totalCompletedSets) séries")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                        
                                        Spacer()
                                        
                                        Text(WorkoutCalculations.formatVolume(workout.totalVolume, unit: gymStore.settings.weightUnit))
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.accentColor)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    gymStore.deleteWorkoutFromHistory(workout)
                                } label: {
                                    Label("Apagar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Pesquisar treinos ou exercícios...")
                }
            }
            .navigationTitle("Histórico")
        }
    }
}
