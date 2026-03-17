package com.nerw.weather.service;

import com.nerw.weather.exception.ExerciseNotFoundException;
import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.Exercise;
import com.nerw.weather.model.ExercisesResponse;
import com.nerw.weather.model.ProgressResponse;
import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.model.WorkoutSet;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FitnessService {

    private final Map<String, Exercise> exercises = new LinkedHashMap<>();
    private final List<StoredWorkout> workouts = new ArrayList<>();

    public FitnessService() {
        seedExercises();
    }

    private void seedExercises() {
        addExercise("ex-001", "Barbell Back Squat", "legs", "barbell",
                "Compound lower-body movement targeting quads, hamstrings, and glutes.");
        addExercise("ex-002", "Bench Press", "chest", "barbell",
                "Horizontal push targeting pectorals, anterior deltoids, and triceps.");
        addExercise("ex-003", "Deadlift", "back", "barbell",
                "Full-body pull targeting erectors, glutes, hamstrings, and traps.");
        addExercise("ex-004", "Pull-Up", "back", "bodyweight",
                "Vertical pull targeting lats, biceps, and rear deltoids.");
        addExercise("ex-005", "Overhead Press", "shoulders", "barbell",
                "Vertical push targeting deltoids, triceps, and upper traps.");
        addExercise("ex-006", "Dumbbell Curl", "arms", "dumbbell",
                "Isolation movement targeting biceps brachii.");
        addExercise("ex-007", "Plank", "core", "bodyweight",
                "Isometric core stabilisation targeting transverse abdominis and obliques.");
        addExercise("ex-008", "Leg Press", "legs", "machine",
                "Compound leg push targeting quads and glutes with reduced spinal load.");
    }

    private void addExercise(String id, String name, String muscleGroup, String equipment, String description) {
        exercises.put(id, new Exercise(id, name, muscleGroup, equipment, description));
    }

    public ExercisesResponse listExercises(String muscleGroup, String equipment) {
        List<Exercise> result = exercises.values().stream()
                .filter(e -> muscleGroup == null || muscleGroup.equalsIgnoreCase(e.muscleGroup()))
                .filter(e -> equipment == null || equipment.equalsIgnoreCase(e.equipment()))
                .collect(Collectors.toList());
        return new ExercisesResponse(result);
    }

    public WorkoutResponse logWorkout(WorkoutRequest request) {
        validateWorkoutRequest(request);

        String workoutId = "wkt-" + UUID.randomUUID().toString().replace("-", "").substring(0, 6);
        int totalSets = request.sets() == null ? 0 : request.sets().size();
        double totalVolume = request.sets() == null ? 0.0 : request.sets().stream()
                .mapToDouble(s -> s.reps() * s.weightKg())
                .sum();

        StoredWorkout stored = new StoredWorkout(
                workoutId,
                request.userId(),
                request.date(),
                request.durationMinutes(),
                request.sets() == null ? List.of() : List.copyOf(request.sets()),
                request.notes()
        );
        synchronized (workouts) {
            workouts.add(stored);
        }

        return new WorkoutResponse(
                workoutId,
                request.userId(),
                request.date(),
                request.durationMinutes(),
                totalSets,
                totalVolume,
                "Workout logged successfully"
        );
    }

    public ProgressResponse getProgress(String userId, String from, String to, String exerciseId) {
        if (userId == null || userId.isBlank()) {
            throw new InvalidRequestException("userId is required");
        }
        LocalDate fromDate = parseDate(from, "from");
        LocalDate toDate = parseDate(to, "to");
        if (fromDate.isAfter(toDate)) {
            throw new InvalidRequestException("'from' must not be after 'to'");
        }

        // TODO: enforce caller identity — any userId can currently be queried by any caller
        List<StoredWorkout> filtered;
        synchronized (workouts) {
            filtered = workouts.stream()
                    .filter(w -> userId.equals(w.userId()))
                    .filter(w -> {
                        LocalDate d = LocalDate.parse(w.date());
                        return !d.isBefore(fromDate) && !d.isAfter(toDate);
                    })
                    .sorted(Comparator.comparing(w -> LocalDate.parse(w.date())))
                    .collect(Collectors.toList());
        }

        double totalVolume = filtered.stream()
                .flatMap(w -> w.sets().stream())
                .filter(s -> exerciseId == null || exerciseId.equals(s.exerciseId()))
                .mapToDouble(s -> s.reps() * s.weightKg())
                .sum();

        Map<String, List<SetWithDate>> setsByExercise = new LinkedHashMap<>();
        for (StoredWorkout w : filtered) {
            for (WorkoutSet s : w.sets()) {
                if (exerciseId != null && !exerciseId.equals(s.exerciseId())) continue;
                setsByExercise.computeIfAbsent(s.exerciseId(), k -> new ArrayList<>())
                        .add(new SetWithDate(w.date(), s));
            }
        }

        List<ProgressResponse.ExerciseProgress> exerciseProgress = new ArrayList<>();
        for (Map.Entry<String, List<SetWithDate>> entry : setsByExercise.entrySet()) {
            String exId = entry.getKey();
            List<SetWithDate> sets = entry.getValue();
            Exercise ex = exercises.get(exId);
            String exName = ex != null ? ex.name() : exId;

            Map<String, List<WorkoutSet>> byDate = sets.stream()
                    .collect(Collectors.groupingBy(
                            SetWithDate::date,
                            LinkedHashMap::new,
                            Collectors.mapping(SetWithDate::set, Collectors.toList())
                    ));

            List<String> sortedDates = byDate.keySet().stream()
                    .sorted()
                    .collect(Collectors.toList());

            if (sortedDates.isEmpty()) continue;

            String firstDate = sortedDates.get(0);
            String lastDate = sortedDates.get(sortedDates.size() - 1);

            ProgressResponse.SessionSummary first = buildSessionSummary(firstDate, byDate.get(firstDate));
            ProgressResponse.SessionSummary last = buildSessionSummary(lastDate, byDate.get(lastDate));

            double delta = first.totalVolume() == 0 ? 0.0
                    : round((last.totalVolume() - first.totalVolume()) / first.totalVolume() * 100, 2);

            exerciseProgress.add(new ProgressResponse.ExerciseProgress(exId, exName, first, last, delta));
        }

        int totalWorkouts = exerciseId == null
                ? filtered.size()
                : (int) filtered.stream()
                        .filter(w -> w.sets().stream().anyMatch(s -> exerciseId.equals(s.exerciseId())))
                        .count();

        return new ProgressResponse(
                userId,
                from,
                to,
                totalWorkouts,
                totalVolume,
                exerciseProgress
        );
    }

    private ProgressResponse.SessionSummary buildSessionSummary(String date, List<WorkoutSet> sets) {
        double maxWeight = sets.stream().mapToDouble(WorkoutSet::weightKg).max().orElse(0.0);
        double vol = sets.stream().mapToDouble(s -> s.reps() * s.weightKg()).sum();
        return new ProgressResponse.SessionSummary(date, maxWeight, vol);
    }

    private void validateWorkoutRequest(WorkoutRequest request) {
        if (request.userId() == null || request.userId().isBlank()) {
            throw new InvalidRequestException("userId is required");
        }
        if (request.date() == null || request.date().isBlank()) {
            throw new InvalidRequestException("date is required");
        }
        parseDate(request.date(), "date");
        if (request.durationMinutes() <= 0) {
            throw new InvalidRequestException("durationMinutes must be positive");
        }
        if (request.sets() == null || request.sets().isEmpty()) {
            throw new InvalidRequestException("sets must not be empty");
        }
        for (WorkoutSet set : request.sets()) {
            if (set.exerciseId() == null || set.exerciseId().isBlank()) {
                throw new InvalidRequestException("Each set must have an exerciseId");
            }
            if (!exercises.containsKey(set.exerciseId())) {
                throw new ExerciseNotFoundException(set.exerciseId());
            }
            if (set.reps() <= 0) {
                throw new InvalidRequestException("reps must be positive");
            }
            if (set.weightKg() < 0) {
                throw new InvalidRequestException("weightKg must not be negative");
            }
        }
    }

    private LocalDate parseDate(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new InvalidRequestException("'" + field + "' is required");
        }
        try {
            return LocalDate.parse(value);
        } catch (DateTimeParseException e) {
            throw new InvalidRequestException("'" + field + "' must be in YYYY-MM-DD format");
        }
    }

    private double round(double value, int scale) {
        return BigDecimal.valueOf(value).setScale(scale, RoundingMode.HALF_UP).doubleValue();
    }

    private record StoredWorkout(
            String workoutId,
            String userId,
            String date,
            int durationMinutes,
            List<WorkoutSet> sets,
            String notes
    ) {}

    private record SetWithDate(String date, WorkoutSet set) {}
}
