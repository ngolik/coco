import SwiftUI

struct WeatherCardView: View {
    let weather: WeatherResponse

    private static let rainySnowyCodes: Set<Int> = [
        176, 185, 263, 266, 281, 284, 293, 296, 299, 302,
        305, 308, 311, 314, 317, 320, 323, 326, 329, 332,
        335, 338, 350, 353, 356, 359, 362, 365, 368, 371,
        374, 377
    ]

    private static let cloudyCodes: Set<Int> = [116, 119, 122]

    static func iconName(for code: String) -> String {
        guard let intCode = Int(code) else { return "cloud.fill" }
        if intCode == 113 { return "sun.max.fill" }
        if cloudyCodes.contains(intCode) { return "cloud.fill" }
        if rainySnowyCodes.contains(intCode) { return "cloud.rain.fill" }
        return "cloud.fill"
    }

    static func iconColor(for code: String) -> Color {
        guard let intCode = Int(code) else { return .gray }
        if intCode == 113 { return .yellow }
        if cloudyCodes.contains(intCode) { return .gray }
        if rainySnowyCodes.contains(intCode) { return .blue }
        return .gray
    }

    static func gradient(for code: String) -> LinearGradient {
        guard let intCode = Int(code) else {
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if intCode == 113 {
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if cloudyCodes.contains(intCode) {
            return LinearGradient(colors: [.gray, Color(white: 0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if rainySnowyCodes.contains(intCode) {
            return LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        VStack(spacing: 16) {
            // City name
            Text(weather.cityName)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Weather icon
            Image(systemName: WeatherCardView.iconName(for: weather.iconCode))
                .font(.system(size: 64))
                .foregroundColor(WeatherCardView.iconColor(for: weather.iconCode))
                .shadow(radius: 4)

            // Temperature
            Text(String(format: "%.0f°C", weather.temperature))
                .font(.system(size: 72, weight: .thin))
                .foregroundColor(.white)

            // Condition
            Text(weather.condition)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))

            Divider()
                .background(Color.white.opacity(0.4))
                .padding(.horizontal)

            // Detail rows
            VStack(spacing: 8) {
                WeatherDetailRow(
                    icon: "thermometer",
                    label: "Feels like",
                    value: String(format: "%.0f°C", weather.feelsLike)
                )
                WeatherDetailRow(
                    icon: "drop.fill",
                    label: "Humidity",
                    value: "\(weather.humidity)%"
                )
                WeatherDetailRow(
                    icon: "wind",
                    label: "Wind",
                    value: String(format: "%.1f km/h", weather.windSpeed)
                )
            }
            .padding(.horizontal)
        }
        .padding(24)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        WeatherCardView(weather: WeatherResponse(
            cityName: "London",
            temperature: 22,
            feelsLike: 20,
            humidity: 65,
            windSpeed: 15.5,
            condition: "Sunny",
            iconCode: "113"
        ))
    }
}
