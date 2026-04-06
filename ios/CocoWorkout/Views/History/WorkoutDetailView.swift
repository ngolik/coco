import SwiftUI

struct WorkoutDetailView: View {
    let workout: CompletedWorkout

    private var logs: [ExerciseLog] {
        if !workout.exerciseLogs.isEmpty { return workout.exerciseLogs }
        try? workout.decodeLogs()
        return workout.exerciseLogs
    }

    var body: some View {
        List {
            Section("Date") {
                Text(workout.date.formatted(date: .complete, time: .shortened))
            }

            Section("Exercises") {
                ForEach(logs, id: \.exerciseName) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(log.exerciseName)
                            .font(.headline)
                        HStack(spacing: 8) {
                            ForEach(Array(log.sets.enumerated()), id: \.offset) { index, done in
                                Image(systemName: done ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(done ? .green : .red)
                                    .imageScale(.medium)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Microcycle \(workout.microcycle) Day \(workout.day)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
