package com.nerw.weather.model;

public record WeatherResponse(
        String cityName,
        double temperature,
        double feelsLike,
        int humidity,
        double windSpeed,
        String condition,
        String iconCode
) {}
