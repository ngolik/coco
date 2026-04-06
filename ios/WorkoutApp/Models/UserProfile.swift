import Foundation
import SwiftData

@Model
final class UserProfile {
    var benchPress1RM: Double
    var squat1RM: Double
    var deadlift1RM: Double
    var updatedAt: Date

    init(benchPress1RM: Double, squat1RM: Double, deadlift1RM: Double) {
        self.benchPress1RM = benchPress1RM
        self.squat1RM = squat1RM
        self.deadlift1RM = deadlift1RM
        self.updatedAt = Date()
    }
}
