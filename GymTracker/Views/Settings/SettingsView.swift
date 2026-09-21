import SwiftUI

public struct SettingsView: View {
    @ObservedObject var gymStore = GymStore.shared
    @State private var exportURL: URL? = nil
    @State private var isShowingShareSheet: Bool = false
    
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
    }
}
