import SwiftData
import Foundation

@Model
final class CachedPlan {
    var rawJSON: String
    var fetchedAt: Date

    @Transient var microcycles: [Microcycle] = []

    init(rawJSON: String) {
        self.rawJSON = rawJSON
        self.fetchedAt = Date()
    }

    func decode() throws {
        let data = Data(rawJSON.utf8)
        microcycles = try JSONDecoder().decode([Microcycle].self, from: data)
    }
}
