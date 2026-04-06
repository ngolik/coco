import SwiftUI
import SwiftData

@main
struct CocoWorkoutApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: UserProfile.self, CachedPlan.self, CompletedWorkout.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
