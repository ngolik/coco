import Foundation
import SwiftData

@Model
final class CompletedWorkout {
    var date: Date
    var microcycle: Int
    var day: Int
    var exerciseLogsJSON: String
    /// Not persisted — recomputed via decodeLogs().
    @Transient var exerciseLogs: [ExerciseLog] = []

    init(date: Date, microcycle: Int, day: Int, exerciseLogs: [ExerciseLog]) throws {
        self.date = date
        self.microcycle = microcycle
        self.day = day
        let data = try JSONEncoder().encode(exerciseLogs)
        self.exerciseLogsJSON = String(data: data, encoding: .utf8) ?? "[]"
        self.exerciseLogs = exerciseLogs
    }

    func decodeLogs() {
        guard let data = exerciseLogsJSON.data(using: .utf8),
              let logs = try? JSONDecoder().decode([ExerciseLog].self, from: data)
        else { return }
        exerciseLogs = logs
    }
}

struct ExerciseLog: Codable {
    var exerciseName: String
    var sets: [Bool]
}
