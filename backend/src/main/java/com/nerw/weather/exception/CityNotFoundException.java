package com.nerw.weather.exception;

public class CityNotFoundException extends RuntimeException {

    private final String city;

    public CityNotFoundException(String city) {
        super("City not found: " + city);
        this.city = city;
    }

    public String getCity() {
        return city;
    }
}
