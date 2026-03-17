# Weather App

iOS + Java Spring Boot weather application using [wttr.in](https://wttr.in) as data source.

## Architecture
- **Backend**: Java 21, Spring Boot 3, proxies wttr.in → `http://localhost:8080/api/weather?city={city}`
- **iOS**: SwiftUI iOS 17+, connects to backend at `http://localhost:8080`

## Prerequisites
- Java 21+
- Maven 3.9+
- Xcode 15+ (for iOS)
- macOS Sonoma+ (for iOS simulator)

## Quick Start

### Backend
```bash
cd backend
mvn spring-boot:run
```
Backend starts on http://localhost:8080

### Test the API
```bash
curl "http://localhost:8080/api/weather?city=London"
```

Expected response:
```json
{
  "cityName": "London",
  "temperature": 15.0,
  "feelsLike": 13.0,
  "humidity": 72,
  "windSpeed": 18.0,
  "condition": "Partly cloudy",
  "iconCode": "116"
}
```

### iOS App
1. Open `ios/WeatherApp.xcodeproj` in Xcode
2. Select iPhone simulator (iOS 17+)
3. Press ▶ Run (Cmd+R)
4. Make sure backend is running at `http://localhost:8080`

## API Reference

### GET /api/weather

| Parameter | Type   | Required | Description         |
|-----------|--------|----------|---------------------|
| city      | string | yes      | City name to search |

**Response fields:**
| Field       | Type   | Description                   |
|-------------|--------|-------------------------------|
| cityName    | string | Resolved city name            |
| temperature | number | Temperature in Celsius        |
| feelsLike   | number | Feels like temperature (°C)   |
| humidity    | int    | Humidity percentage           |
| windSpeed   | number | Wind speed in km/h            |
| condition   | string | Weather condition description |
| iconCode    | string | wttr.in weather code          |

**Error responses:**
- `400` — missing city parameter
- `404` — city not found
- `502` — upstream error from wttr.in

## Features
- Real-time weather data (no API key required)
- Dynamic gradient background (sunny/cloudy/rainy themes)
- Smooth SwiftUI animations
- Search any city worldwide

## Data Source
Weather data provided by [wttr.in](https://wttr.in) — free, no API key required.
