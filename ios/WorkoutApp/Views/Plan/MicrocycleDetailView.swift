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
                            Text("\(exercise.sets) \u{00D7} \(exercise.reps) @ \(Int(exercise.intensityPct * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Rest: \(exercise.effectiveRestSeconds)s")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
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
