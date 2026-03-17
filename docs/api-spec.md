# Fitness API Specification

**Base URL:** `http://localhost:8080/api/fitness`
**Stack:** Java 21 · Spring Boot 3.2 · JSON (camelCase)
**Date:** 2026-03-17

---

## Overview

Three new endpoints extending the existing `/api` prefix to add fitness-domain functionality: exercise catalogue lookup, workout session logging, and progress tracking.

---

## Endpoints

### 1. GET /api/fitness/exercises

List available exercises, optionally filtered by muscle group or equipment.

**Query Parameters**

| Name        | Type   | Required | Description                                              |
|-------------|--------|----------|----------------------------------------------------------|
| muscleGroup | string | no       | Filter by target muscle group (e.g. `chest`, `legs`)     |
| equipment   | string | no       | Filter by equipment type (e.g. `barbell`, `bodyweight`)  |

**Response 200**

```json
{
  "exercises": [
    {
      "id": "ex-001",
      "name": "Barbell Back Squat",
      "muscleGroup": "legs",
      "equipment": "barbell",
      "description": "Compound lower-body movement targeting quads, hamstrings, and glutes."
    },
    {
      "id": "ex-002",
      "name": "Push-Up",
      "muscleGroup": "chest",
      "equipment": "bodyweight",
      "description": "Bodyweight pressing movement targeting chest, shoulders, and triceps."
    }
  ]
}
```

**Response Schema**

| Field                  | Type   | Description                          |
|------------------------|--------|--------------------------------------|
| exercises              | array  | List of exercise objects             |
| exercises[].id         | string | Unique exercise identifier           |
| exercises[].name       | string | Exercise display name                |
| exercises[].muscleGroup| string | Primary muscle group targeted        |
| exercises[].equipment  | string | Equipment required                   |
| exercises[].description| string | Brief description of the exercise    |

**Error Responses**

| Code | Condition                        | Body                                       |
|------|----------------------------------|--------------------------------------------|
| 400  | Unrecognised filter value        | `{"error": "Unknown muscleGroup: xyz"}` |

---

### 2. POST /api/fitness/workouts

Log a completed workout session containing one or more exercise sets.

**Request Body** (`application/json`)

```json
{
  "userId": "usr-42",
  "date": "2026-03-17",
  "durationMinutes": 55,
  "sets": [
    {
      "exerciseId": "ex-001",
      "reps": 8,
      "weightKg": 100.0,
      "setNumber": 1
    },
    {
      "exerciseId": "ex-001",
      "reps": 8,
      "weightKg": 100.0,
      "setNumber": 2
    }
  ],
  "notes": "Felt strong today, increased squat by 5 kg."
}
```

**Request Schema**

| Field                  | Type    | Required | Description                                  |
|------------------------|---------|----------|----------------------------------------------|
| userId                 | string  | yes      | Identifier of the user logging the workout   |
| date                   | string  | yes      | ISO 8601 date (`YYYY-MM-DD`)                 |
| durationMinutes        | integer | yes      | Total workout duration in minutes            |
| sets                   | array   | yes      | Ordered list of exercise sets performed      |
| sets[].exerciseId      | string  | yes      | Reference to an exercise from the catalogue  |
| sets[].reps            | integer | yes      | Repetitions performed in this set            |
| sets[].weightKg        | number  | no       | Load used in kilograms (omit for bodyweight) |
| sets[].setNumber       | integer | yes      | Set order within this exercise               |
| notes                  | string  | no       | Free-text session notes (write-only; not included in response) |

**Response 201**

```json
{
  "workoutId": "wkt-7f3a2c",
  "userId": "usr-42",
  "date": "2026-03-17",
  "durationMinutes": 55,
  "totalSets": 2,
  "totalVolume": 1600.0,
  "message": "Workout logged successfully"
}
```

`totalVolume` = sum of (reps × weightKg) across all sets with a weight.

**Error Responses**

| Code | Condition                                | Body                                              |
|------|------------------------------------------|---------------------------------------------------|
| 400  | Missing required field                   | `{"error": "Field 'userId' is required"}` |
| 400  | Invalid date format                      | `{"error": "Invalid date format, expected YYYY-MM-DD"}` |
| 404  | exerciseId not found in catalogue        | `{"error": "Exercise 'ex-999' not found"}` |

---

### 3. GET /api/fitness/progress

Retrieve aggregated progress metrics for a user over a date range.

**Query Parameters**

| Name      | Type   | Required | Description                                    |
|-----------|--------|----------|------------------------------------------------|
| userId    | string | yes      | User identifier                                |
| from      | string | yes      | Start date inclusive, ISO 8601 (`YYYY-MM-DD`)  |
| to        | string | yes      | End date inclusive, ISO 8601 (`YYYY-MM-DD`)    |
| exerciseId| string | no       | Narrow results to a single exercise            |

**Response 200**

```json
{
  "userId": "usr-42",
  "from": "2026-03-01",
  "to": "2026-03-17",
  "totalWorkouts": 8,
  "totalVolume": 42500.0,
  "exerciseProgress": [
    {
      "exerciseId": "ex-001",
      "exerciseName": "Barbell Back Squat",
      "firstSession": {
        "date": "2026-03-01",
        "maxWeightKg": 95.0,
        "totalVolume": 1520.0
      },
      "lastSession": {
        "date": "2026-03-17",
        "maxWeightKg": 100.0,
        "totalVolume": 1600.0
      },
      "volumeDeltaPct": 5.26
    }
  ]
}
```

**Response Schema**

| Field                                    | Type    | Description                                          |
|------------------------------------------|---------|------------------------------------------------------|
| userId                                   | string  | User the data belongs to                             |
| from                                     | string  | Period start date                                    |
| to                                       | string  | Period end date                                      |
| totalWorkouts                            | integer | Number of workout sessions in the period             |
| totalVolume                              | number  | Total volume (kg) lifted across all sessions         |
| exerciseProgress                         | array   | Per-exercise progression breakdown                   |
| exerciseProgress[].exerciseId            | string  | Exercise identifier                                  |
| exerciseProgress[].exerciseName          | string  | Exercise display name                                |
| exerciseProgress[].firstSession          | object  | Metrics from first session in period                 |
| exerciseProgress[].firstSession.date     | string  | Date of first session                                |
| exerciseProgress[].firstSession.maxWeightKg | number | Heaviest set in that session                    |
| exerciseProgress[].firstSession.totalVolume | number | Total session volume for the exercise           |
| exerciseProgress[].lastSession           | object  | Metrics from most recent session in period           |
| exerciseProgress[].lastSession.date      | string  | Date of last session                                 |
| exerciseProgress[].lastSession.maxWeightKg  | number | Heaviest set in that session                    |
| exerciseProgress[].lastSession.totalVolume  | number | Total session volume for the exercise           |
| exerciseProgress[].volumeDeltaPct        | number  | % change in volume from first to last session        |

**Error Responses**

| Code | Condition                          | Body                                               |
|------|------------------------------------|----------------------------------------------------|
| 400  | Missing required query parameter   | `{"error": "Query parameter 'userId' is required"}` |
| 400  | `from` is after `to`               | `{"error": "Parameter 'from' must not be after 'to'"}` |

---

## Common Error Format

All error responses follow the existing project convention:

```json
{
  "error": "Human-readable message"
}
```

---

## Implementation Notes

- Follow existing package structure: controllers in `com.nerw.weather.controller`, services in `com.nerw.weather.service`, models as Java records.
- All date fields use ISO 8601 strings (`YYYY-MM-DD`) to stay consistent with `@JsonFormat(pattern = "yyyy-MM-dd")`.
- Validation via `@Valid` + Bean Validation (`@NotNull`, `@Min`, `@NotBlank`).
- Fitness data persistence: add `spring-boot-starter-data-jpa` + H2 (dev) / PostgreSQL (prod) to `pom.xml`.
- Map `@ResponseStatus(HttpStatus.CREATED)` on the POST handler; extend `GlobalExceptionHandler` for `ExerciseNotFoundException` and `UserNotFoundException`.
