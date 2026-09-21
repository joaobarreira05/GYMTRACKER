import SwiftUI

public struct TemplatesListView: View {
    @ObservedObject var gymStore = GymStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCreateSheet: Bool = false
    
    public var body: some View {
        List {
            ForEach(gymStore.templates) { template in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            if let notes = template.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if template.isCustom {
                            Text("Custom")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Exercise count and names
                    let exerciseNames = template.exerciseIds.compactMap { id in
                        gymStore.exercises.first(where: { $0.id == id })?.name
                    }
                    
                    if !exerciseNames.isEmpty {
                        Text(exerciseNames.joined(separator: " • "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text("\(template.exerciseIds.count) exercises")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        
                        Spacer()
                        
                        Button {
                            gymStore.startNewWorkout(template: template)
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.caption2)
                                Text("Start")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.vertical, 6)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if template.isCustom {
                        Button(role: .destructive) {
                            gymStore.deleteTemplate(template)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Workout Templates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingCreateSheet) {
            CreateTemplateSheet()
        }
    }
}
