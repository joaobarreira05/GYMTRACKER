import SwiftUI

public struct HomeView: View {
    @ObservedObject var gymStore = GymStore.shared
    @ObservedObject var certManager = CertificateExpirationManager.shared
    @Binding var selectedTab: Int
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        if hour < 12 {
            timeGreeting = "Bom dia"
        } else if hour < 18 {
            timeGreeting = "Boa tarde"
        } else {
            timeGreeting = "Boa noite"
        }
        return "\(timeGreeting), \(gymStore.settings.userName)"
    }
    
    private var lastWorkout: Workout? {
        let calendar = Calendar.current
        return gymStore.workouts.first(where: { !calendar.isDateInToday($0.date) })
    }
    
    private var workoutsThisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return gymStore.workouts.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) && !$0.exercises.isEmpty
        }.count
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Greeting Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text(Date().formatted(date: .complete, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // MARK: - Certificate Warnings (if expiring soon or permissions disabled)
                    if certManager.isExpiringSoon || certManager.isExpired {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundStyle(certManager.isExpired ? .red : .orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(certManager.isExpired ? "Certificado Expirado" : "Certificado a Expirar (\(certManager.remainingFormatted))")
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .foregroundStyle(certManager.isExpired ? .red : .orange)
                                Text("Conecta o iPhone ao Mac e prime Cmd+R no Xcode para renovar sem perder dados.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(certManager.isExpired ? Color.red.opacity(0.12) : Color.orange.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 20)
                    } else if certManager.notificationStatus == .denied {
                        Button {
                            certManager.openSystemSettings()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.slash.fill")
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notificações Desativadas no iPhone")
                                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        .foregroundStyle(.primary)
                                    Text("Toca aqui para permitir alertas e seres avisado 24h antes da app expirar.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Today's Sheet Quick Access
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Treino de Hoje")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        Button {
                            selectedTab = 1 // Switch to Workout Tab
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(gymStore.activeWorkout?.name ?? "Treino de Hoje")
                                            .font(.system(.title3, design: .rounded, weight: .bold))
                                            .foregroundStyle(.white)
                                        
                                        let count = gymStore.activeWorkout?.exercises.count ?? 0
                                        Text(count == 0 ? "Folha em branco • Toca para apontar" : "\(count) exercícios registados hoje")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.85))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                                
                                if let exercises = gymStore.activeWorkout?.exercises, !exercises.isEmpty {
                                    Text(exercises.map(\.exerciseName).joined(separator: " • "))
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.75))
                                        .lineLimit(1)
                                }
                            }
                            .padding(18)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.25), radius: 10, y: 4)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Quick Routine Templates
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Modelos de Treino (Templates)")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            NavigationLink {
                                TemplatesListView()
                            } label: {
                                Text("Ver Todos")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(gymStore.templates) { template in
                                    Button {
                                        gymStore.loadTemplateIntoToday(template)
                                        selectedTab = 1
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Image(systemName: "figure.strengthtraining.traditional")
                                                    .font(.headline)
                                                    .foregroundStyle(.orange)
                                                Spacer()
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(Color.accentColor)
                                            }
                                            
                                            Text(template.name)
                                                .font(.system(.headline, design: .rounded, weight: .bold))
                                                .foregroundStyle(.primary)
                                            
                                            Text("\(template.exerciseIds.count) exercícios")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(14)
                                        .frame(width: 160, alignment: .leading)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Last Workout Card
                    if let last = lastWorkout {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Último Treino Registado")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    gymStore.copyWorkoutToToday(last)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                        Text("Repetir Hoje")
                                    }
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            NavigationLink {
                                WorkoutDetailView(workout: last)
                            } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(last.name)
                                                .font(.system(.title3, design: .rounded, weight: .bold))
                                                .foregroundStyle(.primary)
                                            
                                            Text(last.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption.bold())
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    if !last.exercises.isEmpty {
                                        Text(last.exercises.map(\.exerciseName).joined(separator: " • "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("\(last.totalCompletedSets) séries")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("Volume: \(WorkoutCalculations.formatVolume(last.totalVolume, unit: gymStore.settings.weightUnit))")
                                            .font(.caption2.bold())
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .padding(16)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // MARK: - Weekly Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Atividade")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            QuickStatCard(
                                title: "Esta Semana",
                                value: "\(workoutsThisWeekCount)",
                                icon: "flame.fill",
                                iconColor: .red,
                                subtitle: "dias de treino"
                            )
                            
                            QuickStatCard(
                                title: "Total Registado",
                                value: "\(gymStore.workouts.filter { !$0.exercises.isEmpty }.count)",
                                icon: "trophy.fill",
                                iconColor: .yellow,
                                subtitle: "dias no histórico"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}
