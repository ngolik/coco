import SwiftUI

struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24)

            Text(label)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        VStack {
            WeatherDetailRow(icon: "thermometer", label: "Feels like", value: "20°C")
            WeatherDetailRow(icon: "drop.fill", label: "Humidity", value: "65%")
            WeatherDetailRow(icon: "wind", label: "Wind", value: "15.5 km/h")
        }
        .padding()
    }
}
