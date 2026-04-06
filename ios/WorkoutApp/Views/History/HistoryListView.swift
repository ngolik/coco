import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(sort: \CompletedWorkout.date, order: .reverse)
    private var history: [CompletedWorkout]

    var body: some View {
        Group {
            if history.isEmpty {
                ContentUnavailableView(
                    "No Workouts Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Completed workouts will appear here.")
                )
            } else {
                List(history) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.date, style: .date)
                                .font(.headline)
                            Text("Microcycle \(workout.microcycle) \u{2014} Day \(workout.day)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}
