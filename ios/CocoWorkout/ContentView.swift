import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                PlanView()
            }
            .tabItem {
                Label("Plan", systemImage: "list.bullet.clipboard")
            }

            NavigationStack {
                NextWorkoutView()
            }
            .tabItem {
                Label("Workout", systemImage: "figure.strengthtraining.traditional")
            }

            NavigationStack {
                ProgramsView()
            }
            .tabItem {
                Label("Программы", systemImage: "dumbbell")
            }

            NavigationStack {
                HistoryListView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
        }
    }
}
