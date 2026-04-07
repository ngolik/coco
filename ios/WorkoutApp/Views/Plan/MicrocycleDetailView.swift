import SwiftUI

struct MicrocycleDetailView: View {
    let microcycle: Microcycle
    let doneSet: Set<String>

    var body: some View {
        List {
            ForEach(microcycle.days) { day in
                Section {
                    HStack {
                        Text(day.label).font(.headline)
                        Spacer()
                        if doneSet.contains("\(microcycle.id)-\(day.id)") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    ForEach(day.exercises) { exercise in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name).font(.subheadline)
                            ForEach(Array(exercise.sets.enumerated()), id: \.offset) { idx, set in
                                Text("Set \(idx + 1): \(set.reps) reps × \(String(format: "%.1f", set.weightKg)) kg")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text(day.label)
                }
            }
        }
        .navigationTitle(microcycle.label)
        .navigationBarTitleDisplayMode(.inline)
    }
}
