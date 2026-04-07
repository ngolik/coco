import Foundation

struct WorkoutPlanRequest: Encodable {
    let benchPress1RM: Double
    let squat1RM: Double
    let deadlift1RM: Double

    enum CodingKeys: String, CodingKey {
        case benchPress1RM = "bench_press_1rm"
        case squat1RM      = "squat_1rm"
        case deadlift1RM   = "deadlift_1rm"
    }
}

struct Microcycle: Codable, Identifiable {
    let microcycle: Int
    let days: [TrainingDay]

    var id: Int { microcycle }
    var label: String { "Microcycle \(microcycle)" }
}

struct TrainingDay: Codable, Identifiable {
    let day: Int
    let exercises: [Exercise]

    var id: Int { day }
    var label: String { "Day \(day)" }
}

struct Exercise: Codable, Identifiable {
    let name: String
    let sets: [WorkoutSet]

    var id: String { name }
}

struct WorkoutSet: Codable, Identifiable {
    let weightKg: Double
    let reps: Int

    var id: String { "\(weightKg)-\(reps)" }

    enum CodingKeys: String, CodingKey {
        case weightKg = "weight_kg"
        case reps
    }
}
