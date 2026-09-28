import SwiftUI

public struct SettingsView: View {
    @ObservedObject var gymStore = GymStore.shared
    @ObservedObject var certManager = CertificateExpirationManager.shared
    
    @State private var exportURL: URL? = nil
    @State private var isShowingShareSheet: Bool = false
    @State private var isShowingRenewalGuide: Bool = false
    @State private var testNotificationMessage: String? = nil
    
    public var body: some View {
        Form {
            // MARK: - Profile / Greeting
            Section("Profile") {
                HStack {
                    Text("Your Name")
                    Spacer()
                    TextField("Name", text: Binding(
                        get: { gymStore.settings.userName },
                        set: { newName in
                            var s = gymStore.settings
                            s.userName = newName
                            gymStore.updateSettings(s)
                        }
                    ))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Certificate & 4h Expiration Alert
            Section("Certificado & Validade (Apple Dev)") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(certManager.isExpired ? "Certificado Expirado" : (certManager.isExpiringSoon ? "Expira em Breve" : "Certificado Válido"),
                              systemImage: certManager.isExpired ? "xmark.circle.fill" : (certManager.isExpiringSoon ? "exclamationmark.triangle.fill" : "checkmark.seal.fill"))
                            .font(.subheadline.bold())
                            .foregroundStyle(certManager.isExpired ? .red : (certManager.isExpiringSoon ? .orange : .green))
                        
                        Spacer()
                        
                        Text(certManager.remainingFormatted)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(certManager.isExpired ? Color.red.opacity(0.15) : (certManager.isExpiringSoon ? Color.orange.opacity(0.15) : Color.green.opacity(0.15)))
                            .foregroundStyle(certManager.isExpired ? .red : (certManager.isExpiringSoon ? .orange : .green))
                            .clipShape(Capsule())
                    }
                    
                    HStack {
                        Text("Data de Expiração:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(certManager.expirationDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption.bold())
                    }
                }
                .padding(.vertical, 4)
                
                Toggle("Avisar Antes de Expirar", isOn: $certManager.isNotificationEnabled)
                    .onChange(of: certManager.isNotificationEnabled) { enabled in
                        if enabled && certManager.notificationStatus != .authorized {
                            certManager.requestPermissionAndSchedule()
                        }
                    }
                
                if certManager.isNotificationEnabled {
                    Picker("Antecedência", selection: $certManager.timingPreference) {
                        ForEach(NotificationTimingPreference.allCases) { pref in
                            Text(pref.rawValue).tag(pref)
                        }
                    }
                    
                    if certManager.isNotificationScheduled {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(Color.accentColor)
                                .font(.caption)
                            Text("Alerta agendado para: \(certManager.primaryNotificationTargetDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else if certManager.notificationStatus == .denied {
                        Text("⚠️ Notificações bloqueadas no iOS. Ativa as notificações do GymTracker para receber o alerta de expiração.")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                
                Button {
                    certManager.sendTestNotification { success in
                        if success {
                            testNotificationMessage = "Alerta enviado! Bloqueia o ecrã ou sai da app para ver o banner em 5s."
                        } else {
                            testNotificationMessage = "Autoriza as notificações nas Definições do iPhone."
                        }
                    }
                } label: {
                    Label("Testar Notificação Agora (5s)", systemImage: "bell.and.waves.left.and.right")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                }
                
                if let msg = testNotificationMessage {
                    Text(msg)
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .padding(.vertical, 2)
                }
                
                Button {
                    isShowingRenewalGuide = true
                } label: {
                    Label("Como renovar o certificado?", systemImage: "questionmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
            
            // MARK: - Units
            Section("Units") {
                Picker("Weight Unit", selection: Binding(
                    get: { gymStore.settings.weightUnit },
                    set: { newUnit in
                        var s = gymStore.settings
                        s.weightUnit = newUnit
                        gymStore.updateSettings(s)
                        HapticFeedback.selection()
                    }
                )) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue.uppercased()).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // MARK: - Appearance
            Section("Appearance") {
                Picker("Theme", selection: Binding(
                    get: { gymStore.settings.appearance },
                    set: { newMode in
                        var s = gymStore.settings
                        s.appearance = newMode
                        gymStore.updateSettings(s)
                        HapticFeedback.selection()
                    }
                )) {
                    ForEach(AppAppearance.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }
            
            // MARK: - Rest Timer Preferences
            Section("Rest Timer") {
                Toggle("Auto-start Rest Timer on Complete", isOn: Binding(
                    get: { gymStore.settings.autoStartRestTimer },
                    set: { val in
                        var s = gymStore.settings
                        s.autoStartRestTimer = val
                        gymStore.updateSettings(s)
                    }
                ))
                
                Picker("Default Duration", selection: Binding(
                    get: { gymStore.settings.defaultRestDuration },
                    set: { dur in
                        var s = gymStore.settings
                        s.defaultRestDuration = dur
                        gymStore.updateSettings(s)
                    }
                )) {
                    Text("60 seconds").tag(60)
                    Text("90 seconds").tag(90)
                    Text("120 seconds").tag(120)
                    Text("180 seconds").tag(180)
                }
            }
            
            // MARK: - Local Data & Export
            Section("Data & Storage") {
                HStack {
                    Text("Total Workouts Completed")
                    Spacer()
                    Text("\(gymStore.workouts.count)")
                        .foregroundStyle(.secondary)
                        .bold()
                }
                
                HStack {
                    Text("Total Exercises in Library")
                    Spacer()
                    Text("\(gymStore.exercises.count)")
                        .foregroundStyle(.secondary)
                        .bold()
                }
                
                Button {
                    if let url = gymStore.exportData() {
                        exportURL = url
                        isShowingShareSheet = true
                        HapticFeedback.medium()
                    }
                } label: {
                    Label("Export Workout Data (JSON)", systemImage: "square.and.arrow.up")
                        .foregroundStyle(Color.accentColor)
                }
            }
            
            // MARK: - Privacy & Offline Info
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.green)
                        Text("100% Offline & Private")
                            .font(.subheadline.bold())
                    }
                    
                    Text("Gym Tracker never connects to external servers, cloud databases, or tracking services. All workouts, weights, and records live entirely on your iPhone.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $isShowingShareSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $isShowingRenewalGuide) {
            RenewalGuideSheet()
        }
    }
}

public struct RenewalGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Como renovar o certificado")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        
                        Text("As contas gratuitas da Apple (Free Personal Apple ID) assinam aplicações para iPhone com validade de 7 dias. Ao renovar pelo Mac, todos os teus dados continuam salvos no iPhone!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 6)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        RenewalStepRow(number: "1", title: "Ligar o iPhone ao Mac", detail: "Conecta o teu iPhone ao Mac usando o cabo USB (ou Wi-Fi).")
                        RenewalStepRow(number: "2", title: "Abrir o Xcode", detail: "Abre a pasta do projeto no Mac e clica em GymTracker.xcodeproj.")
                        RenewalStepRow(number: "3", title: "Selecionar o iPhone", detail: "No seletor de destinos no topo do Xcode, certifica-te de que o teu iPhone físico está selecionado.")
                        RenewalStepRow(number: "4", title: "Premir Cmd + R (Run)", detail: "Clica no botão Play ▶️ ou prime Cmd+R. O Xcode gera um novo certificado de 7 dias.")
                        RenewalStepRow(number: "5", title: "Tudo Pronto!", detail: "A app abre no iPhone renovada por mais 7 dias. Os teus treinos e pesos continuam intactos!")
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Text("Não apagues a aplicação do iPhone! A compilação pelo Xcode atualiza a app sem tocar nos teus dados locais.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(20)
            }
            .navigationTitle("Renovar Certificado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Entendido") {
                        dismiss()
                    }
                }
            }
        }
    }
}

public struct RenewalStepRow: View {
    let number: String
    let title: String
    let detail: String
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.accentColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
