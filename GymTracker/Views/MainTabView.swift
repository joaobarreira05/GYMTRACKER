import SwiftUI

public struct MainTabView: View {
    @ObservedObject var gymStore = GymStore.shared
    
    public var body: some View {
        TabView(selection: $gymStore.selectedTab) {
            HomeView(selectedTab: $gymStore.selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ActiveWorkoutView()
                .tabItem {
                    Label("Workout", systemImage: "figure.strengthtraining.traditional")
                }
                .badge(gymStore.activeWorkout != nil && !gymStore.activeWorkout!.exercises.isEmpty ? "\(gymStore.activeWorkout!.exercises.count)" : nil)
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
            
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
                .tag(3)
        }
    }
}
