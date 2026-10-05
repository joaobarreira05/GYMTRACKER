import SwiftUI

public struct WorkoutCalendarView: View {
    @ObservedObject var gymStore = GymStore.shared
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var workoutToRename: Workout? = nil
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "pt_PT")
        cal.firstWeekday = 2 // Monday
        return cal
    }
    
    private var weekdays: [String] {
        ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    // Workouts for the currently displayed month
    private var monthWorkouts: [Workout] {
        gymStore.workouts.filter {
            !$0.exercises.isEmpty && calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
        }
    }
    
    // Workouts for the selected date (or all in month if none selected)
    private var displayedWorkouts: [Workout] {
        if let selected = selectedDate {
            return gymStore.workouts.filter {
                !$0.exercises.isEmpty && calendar.isDate($0.date, inSameDayAs: selected)
            }
        } else {
            return monthWorkouts
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Calendar Container Card
                VStack(spacing: 14) {
                    // Month Navigation Header
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 36, height: 36)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(monthYearString)
                                .font(.system(.title3, design: .rounded, weight: .bold))
                            
                            let count = monthWorkouts.count
                            Text("\(count) \(count == 1 ? "treino" : "treinos")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 36, height: 36)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Days Grid
                    let days = daysInCurrentMonth()
                    let leadingBlanks = leadingBlankDays()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                        // Empty blanks before 1st of month
                        ForEach(0..<leadingBlanks, id: \.self) { _ in
                            Color.clear
                                .frame(height: 44)
                        }
                        
                        // Days in month
                        ForEach(days, id: \.self) { date in
                            let dayWorkouts = gymStore.workouts.filter {
                                !$0.exercises.isEmpty && calendar.isDate($0.date, inSameDayAs: date)
                            }
                            let hasWorkout = !dayWorkouts.isEmpty
                            let isSelected = selectedDate != nil && calendar.isDate(selectedDate!, inSameDayAs: date)
                            let isToday = calendar.isDateInToday(date)
                            
                            // Dominant muscle for the day across all workouts that day
                            let dominantMuscle = dayWorkouts.compactMap(\.dominantMuscleGroup).first
                            let dominantColor = dominantMuscle?.themeColor ?? Color.accentColor
                            
                            // Colors for all muscles trained that day (for dots)
                            let allMuscleColors: [Color] = Array(
                                dayWorkouts.flatMap { $0.muscleBreakdown.map(\.muscle.themeColor) }
                            ).reduce(into: [Color]()) { result, color in
                                if !result.contains(color) { result.append(color) }
                            }
                            
                            Button {
                                if isSelected {
                                    selectedDate = nil // Toggle off selection
                                } else {
                                    selectedDate = date
                                }
                                HapticFeedback.selection()
                            } label: {
                                VStack(spacing: 3) {
                                    // Day Number
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 15, weight: isSelected || isToday || hasWorkout ? .bold : .regular, design: .rounded))
                                        .foregroundStyle(
                                            isSelected ? Color.white :
                                            (hasWorkout ? Color.primary : Color.secondary)
                                        )
                                        .frame(width: 32, height: 32)
                                        .background(
                                            isSelected ? dominantColor :
                                            (isToday ? Color.accentColor.opacity(0.15) : Color.clear)
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            isToday && !isSelected ?
                                                Circle().stroke(Color.accentColor, lineWidth: 1.5) : nil
                                        )
                                    
                                    // Muscle Indicator Dots (like Image 2!)
                                    if hasWorkout {
                                        HStack(spacing: 2.5) {
                                            ForEach(Array(allMuscleColors.prefix(4).enumerated()), id: \.offset) { _, color in
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 4.5, height: 4.5)
                                            }
                                        }
                                        .frame(height: 5)
                                    } else {
                                        Color.clear.frame(height: 5)
                                    }
                                }
                                .frame(height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Legend / Muscle colors key (expandable or compact)
                    Divider().padding(.top, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(MuscleGroup.allCases) { muscle in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(muscle.themeColor)
                                        .frame(width: 7, height: 7)
                                    Text(muscle.shortPortugueseName)
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 16)
                
                // MARK: - Workouts on Selected Date or Month
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        if let selected = selectedDate {
                            Text(selected.formatted(date: .complete, time: .omitted).capitalized)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            
                            Spacer()
                            
                            Button("Ver Todos do Mês") {
                                selectedDate = nil
                                HapticFeedback.selection()
                            }
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                        } else {
                            Text("Treinos de \(monthYearString)")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                            
                            Spacer()
                            
                            Text("\(displayedWorkouts.count) registados")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if displayedWorkouts.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary.opacity(0.6))
                            Text(selectedDate == nil ? "Sem treinos registados neste mês." : "Sem treinos registados neste dia.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(displayedWorkouts) { workout in
                                NavigationLink {
                                    WorkoutDetailView(workout: workout)
                                } label: {
                                    WorkoutHistoryCard(
                                        workout: workout,
                                        onRenameTapped: {
                                            workoutToRename = workout
                                        }
                                    )
                                    .padding(12)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .sheet(item: $workoutToRename) { workout in
            RenameWorkoutSheet(workout: workout) { newName in
                gymStore.renameWorkout(id: workout.id, newName: newName)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newDate
            selectedDate = nil
            HapticFeedback.selection()
        }
    }
    
    private func leadingBlankDays() -> Int {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth) else { return 0 }
        let weekday = calendar.component(.weekday, from: interval.start)
        // Calendar weekday: 1 = Sun, 2 = Mon ... 7 = Sat
        // Monday-based index: Mon -> 0, Tue -> 1, ..., Sun -> 6
        return (weekday + 5) % 7
    }
    
    private func daysInCurrentMonth() -> [Date] {
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date] = []
        var current = interval.start
        while current < interval.end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
}
