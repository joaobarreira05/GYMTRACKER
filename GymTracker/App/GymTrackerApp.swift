import SwiftUI

@main
struct GymTrackerApp: App {
    @StateObject private var gymStore = GymStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gymStore)
                .preferredColorScheme(gymStore.settings.appearance.colorScheme)
        }
    }
}
