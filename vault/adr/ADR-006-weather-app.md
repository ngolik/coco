# ADR-006: Weather App — Data Source and Architecture

| Field    | Value                     |
|----------|---------------------------|
| Date     | 2026-03-17                |
| Status   | Accepted                  |
| Deciders | architect agent           |

---

## Context

The Weather App needs a reliable source of current weather data. Common options
include OpenWeatherMap, WeatherAPI, and wttr.in. The choice affects whether an
API key is required, how complex the integration is, and how suitable the data
format is for the response model.

---

## Decision

Use **wttr.in** as the weather data source.

### Rationale

- Free to use with no API key or account registration required.
- Provides a stable JSON endpoint (`?format=j1`) that includes all fields needed
  by the response model.
- Reduces operational overhead — no key rotation, no quota management.
- Suitable for development and MVP stages; can be swapped for a commercial
  provider later without changing the public API contract (the OpenAPI spec
  remains unchanged).

---

## Data Source Details

### Request URL

```
GET https://wttr.in/{city}?format=j1
```

Example:

```
GET https://wttr.in/London?format=j1
```

### JSON Field Mapping

The table below shows how wttr.in response fields map to the Weather App API
response model defined in `backend/openapi.yaml`.

| API field      | wttr.in JSON path                                  | Notes                        |
|----------------|----------------------------------------------------|------------------------------|
| `temperature`  | `current_condition[0].temp_C`                      | Celsius                      |
| `feels_like`   | `current_condition[0].FeelsLikeC`                  | Celsius                      |
| `humidity`     | `current_condition[0].humidity`                    | Percent (0–100)              |
| `wind_speed`   | `current_condition[0].windspeedKmph`               | km/h                         |
| `condition`    | `current_condition[0].weatherDesc[0].value`        | English description string   |
| `icon_code`    | `current_condition[0].weatherCode`                 | Numeric code as string       |
| `city_name`    | `nearest_area[0].areaName[0].value`                | Resolved name from wttr.in   |

### Error Handling

| wttr.in behaviour                          | API response |
|--------------------------------------------|--------------|
| HTTP 200 but empty / unknown city result   | 404          |
| HTTP 4xx from wttr.in                      | 404          |
| HTTP 5xx or network timeout from wttr.in   | 502          |
| Missing `city` query param in our API      | 400          |

---

## CORS Configuration

During local development the frontend (e.g. React/Vite on `localhost:5173`)
makes requests to the backend on `localhost:8080`. To allow this the backend
must set CORS headers.

**Allowed origins (development):**

```
http://localhost:3000
http://localhost:5173
```

**Allowed methods:** `GET, OPTIONS`

**Allowed headers:** `Content-Type`

In production, replace the wildcard/localhost origins with the actual domain and
use environment-variable-driven configuration so the same binary works in both
environments.

---

## Consequences

- No ongoing cost or credential management for the data source.
- The backend acts as a thin proxy/transformer — it fetches from wttr.in,
  maps the fields listed above, and returns the canonical JSON shape.
- If wttr.in is unavailable, the entire weather feature is unavailable. A future
  improvement could add a secondary provider fallback.
- All numeric values from wttr.in are returned as-is (strings from JSON parsed
  to appropriate numeric types) to avoid precision loss.
