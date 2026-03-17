package com.nerw.weather.service;

import com.nerw.weather.exception.CityNotFoundException;
import com.nerw.weather.model.WeatherResponse;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.util.List;
import java.util.Map;

@Service
public class WeatherService {

    private final WebClient webClient;

    public WeatherService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder
                .baseUrl("https://wttr.in")
                .build();
    }

    public WeatherResponse getWeather(String city) {
        WttrResponse wttrResponse;
        try {
            wttrResponse = webClient.get()
                    .uri("/{city}?format=j1", city)
                    .retrieve()
                    .bodyToMono(WttrResponse.class)
                    .block();
        } catch (WebClientResponseException.NotFound e) {
            throw new CityNotFoundException(city);
        } catch (Exception e) {
            throw new CityNotFoundException(city);
        }

        if (wttrResponse == null
                || wttrResponse.current_condition() == null
                || wttrResponse.current_condition().isEmpty()
                || wttrResponse.nearest_area() == null
                || wttrResponse.nearest_area().isEmpty()) {
            throw new CityNotFoundException(city);
        }

        CurrentCondition cc = wttrResponse.current_condition().get(0);
        NearestArea area = wttrResponse.nearest_area().get(0);

        String cityName = (area.areaName() != null && !area.areaName().isEmpty())
                ? area.areaName().get(0).value()
                : city;

        String condition = (cc.weatherDesc() != null && !cc.weatherDesc().isEmpty())
                ? cc.weatherDesc().get(0).value()
                : "";

        double temperature = parseDouble(cc.temp_C());
        double feelsLike = parseDouble(cc.FeelsLikeC());
        int humidity = parseInt(cc.humidity());
        double windSpeed = parseDouble(cc.windspeedKmph());
        String iconCode = cc.weatherCode() != null ? cc.weatherCode() : "";

        return new WeatherResponse(cityName, temperature, feelsLike, humidity, windSpeed, condition, iconCode);
    }

    private double parseDouble(String value) {
        if (value == null) return 0.0;
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    private int parseInt(String value) {
        if (value == null) return 0;
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // --- DTO records for wttr.in JSON response ---

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record WttrResponse(
            List<CurrentCondition> current_condition,
            List<NearestArea> nearest_area
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record CurrentCondition(
            String temp_C,
            String FeelsLikeC,
            String humidity,
            String windspeedKmph,
            String weatherCode,
            List<ValueWrapper> weatherDesc
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record NearestArea(
            List<ValueWrapper> areaName
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ValueWrapper(String value) {}
}
