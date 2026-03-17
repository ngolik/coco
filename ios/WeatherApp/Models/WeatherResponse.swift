import Foundation

struct WeatherResponse: Codable {
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let condition: String
    let iconCode: String
}
