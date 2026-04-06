import SwiftUI
import SwiftData

@main
struct WorkoutAppApp: App {
    let container = try! ModelContainer(
        for: UserProfile.self, CachedPlan.self, CompletedWorkout.self
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
