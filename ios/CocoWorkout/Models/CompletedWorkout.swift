import SwiftData
import Foundation

@Model
final class CompletedWorkout {
    var date: Date
    var microcycle: Int
    var day: Int
    var exerciseLogsJSON: String

    @Transient var exerciseLogs: [ExerciseLog] = []

    init(date: Date, microcycle: Int, day: Int, exerciseLogs: [ExerciseLog]) throws {
        self.date = date
        self.microcycle = microcycle
        self.day = day
        let data = try JSONEncoder().encode(exerciseLogs)
        self.exerciseLogsJSON = String(data: data, encoding: .utf8) ?? "[]"
        self.exerciseLogs = exerciseLogs
    }

    func decodeLogs() throws {
        let data = Data(exerciseLogsJSON.utf8)
        exerciseLogs = try JSONDecoder().decode([ExerciseLog].self, from: data)
    }
}

struct ExerciseLog: Codable {
    var exerciseName: String
    var sets: [Bool]
}
