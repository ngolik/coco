import SwiftUI

struct MicrocycleDetailView: View {
    let microcycle: Microcycle
    let completed: [CompletedWorkout]

    var body: some View {
        List(microcycle.days) { day in
            let isDone = completed.contains { $0.microcycle == microcycle.id && $0.day == day.id }
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.label)
                        .font(.headline)
                    Text("\(day.exercises.count) exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle(microcycle.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}
