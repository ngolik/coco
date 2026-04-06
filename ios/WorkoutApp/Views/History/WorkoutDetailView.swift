import SwiftUI

struct WorkoutDetailView: View {
    let workout: CompletedWorkout

    @State private var logs: [ExerciseLog] = []

    var body: some View {
        List {
            Section("Session Info") {
                LabeledContent("Date", value: workout.date.formatted(date: .long, time: .shortened))
                LabeledContent("Microcycle", value: "\(workout.microcycle)")
                LabeledContent("Day", value: "\(workout.day)")
            }
            ForEach(logs, id: \.exerciseName) { log in
                Section(log.exerciseName) {
                    ForEach(Array(log.sets.enumerated()), id: \.offset) { idx, done in
                        HStack {
                            Text("Set \(idx + 1)")
                            Spacer()
                            Image(systemName: done ? "checkmark.circle.fill" : "xmark.circle")
                                .foregroundStyle(done ? .green : .red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Workout Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            workout.decodeLogs()
            logs = workout.exerciseLogs
        }
    }
}
