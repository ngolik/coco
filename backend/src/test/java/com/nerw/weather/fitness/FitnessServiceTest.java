package com.nerw.weather.fitness;

import com.nerw.weather.exception.ExerciseNotFoundException;
import com.nerw.weather.exception.InvalidRequestException;
import com.nerw.weather.model.ExercisesResponse;
import com.nerw.weather.model.ProgressResponse;
import com.nerw.weather.model.WorkoutRequest;
import com.nerw.weather.model.WorkoutResponse;
import com.nerw.weather.model.WorkoutSet;
import com.nerw.weather.service.FitnessService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class FitnessServiceTest {

    private FitnessService service;

    @BeforeEach
    void setUp() {
        service = new FitnessService();
    }

    @Test
    void listExercises_returnsAll_whenNoFilter() {
        ExercisesResponse response = service.listExercises(null, null);
        assertThat(response.exercises()).hasSize(8);
    }

    @Test
    void listExercises_filtersByMuscleGroup() {
        ExercisesResponse response = service.listExercises("legs", null);
        assertThat(response.exercises()).allMatch(e -> "legs".equalsIgnoreCase(e.muscleGroup()));
        assertThat(response.exercises()).hasSize(2);
    }

    @Test
    void listExercises_filtersByEquipment() {
        ExercisesResponse response = service.listExercises(null, "barbell");
        assertThat(response.exercises()).allMatch(e -> "barbell".equalsIgnoreCase(e.equipment()));
    }

    @Test
    void listExercises_filtersByMuscleGroupAndEquipment() {
        ExercisesResponse response = service.listExercises("legs", "barbell");
        assertThat(response.exercises()).hasSize(1);
        assertThat(response.exercises().get(0).id()).isEqualTo("ex-001");
    }

    @Test
    void listExercises_returnsEmpty_whenNoMatch() {
        ExercisesResponse response = service.listExercises("nonexistent", null);
        assertThat(response.exercises()).isEmpty();
    }

    @Test
    void logWorkout_returnsCorrectResponse() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42",
                "2026-03-17",
                55,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1)),
                "Increased squat by 5 kg."
        );

        WorkoutResponse response = service.logWorkout(request);

        assertThat(response.workoutId()).startsWith("wkt-");
        assertThat(response.userId()).isEqualTo("usr-42");
        assertThat(response.date()).isEqualTo("2026-03-17");
        assertThat(response.durationMinutes()).isEqualTo(55);
        assertThat(response.totalSets()).isEqualTo(1);
        assertThat(response.totalVolume()).isEqualTo(800.0);
        assertThat(response.message()).isEqualTo("Workout logged successfully");
    }

    @Test
    void logWorkout_calculatesTotalVolume_multiplesSets() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42",
                "2026-03-17",
                60,
                List.of(
                        new WorkoutSet("ex-001", 10, 100.0, 1),
                        new WorkoutSet("ex-001", 8, 105.0, 2),
                        new WorkoutSet("ex-001", 6, 110.0, 3)
                ),
                null
        );

        WorkoutResponse response = service.logWorkout(request);

        assertThat(response.totalSets()).isEqualTo(3);
        assertThat(response.totalVolume()).isEqualTo(10 * 100.0 + 8 * 105.0 + 6 * 110.0);
    }

    @Test
    void logWorkout_throwsOnMissingUserId() {
        WorkoutRequest request = new WorkoutRequest(
                null, "2026-03-17", 55,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1)), null);

        assertThatThrownBy(() -> service.logWorkout(request))
                .isInstanceOf(InvalidRequestException.class)
                .hasMessageContaining("userId");
    }

    @Test
    void logWorkout_throwsOnInvalidDate() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42", "not-a-date", 55,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1)), null);

        assertThatThrownBy(() -> service.logWorkout(request))
                .isInstanceOf(InvalidRequestException.class)
                .hasMessageContaining("date");
    }

    @Test
    void logWorkout_throwsOnNonPositiveDuration() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42", "2026-03-17", 0,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1)), null);

        assertThatThrownBy(() -> service.logWorkout(request))
                .isInstanceOf(InvalidRequestException.class)
                .hasMessageContaining("durationMinutes");
    }

    @Test
    void logWorkout_throwsOnEmptySets() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42", "2026-03-17", 55, List.of(), null);

        assertThatThrownBy(() -> service.logWorkout(request))
                .isInstanceOf(InvalidRequestException.class)
                .hasMessageContaining("sets");
    }

    @Test
    void logWorkout_throwsOnUnknownExerciseId() {
        WorkoutRequest request = new WorkoutRequest(
                "usr-42", "2026-03-17", 55,
                List.of(new WorkoutSet("ex-999", 8, 100.0, 1)), null);

        assertThatThrownBy(() -> service.logWorkout(request))
                .isInstanceOf(ExerciseNotFoundException.class)
                .hasMessageContaining("ex-999");
    }

    @Test
    void getProgress_returnsCorrectMetrics() {
        // Log two workouts for the same exercise on different dates
        service.logWorkout(new WorkoutRequest("usr-1", "2026-03-01", 45,
                List.of(new WorkoutSet("ex-001", 8, 95.0, 1),
                        new WorkoutSet("ex-001", 8, 95.0, 2)), null));
        service.logWorkout(new WorkoutRequest("usr-1", "2026-03-17", 50,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1),
                        new WorkoutSet("ex-001", 8, 100.0, 2)), null));

        ProgressResponse progress = service.getProgress("usr-1", "2026-03-01", "2026-03-17", null);

        assertThat(progress.userId()).isEqualTo("usr-1");
        assertThat(progress.totalWorkouts()).isEqualTo(2);
        assertThat(progress.exerciseProgress()).hasSize(1);

        ProgressResponse.ExerciseProgress ep = progress.exerciseProgress().get(0);
        assertThat(ep.exerciseId()).isEqualTo("ex-001");
        assertThat(ep.firstSession().date()).isEqualTo("2026-03-01");
        assertThat(ep.firstSession().maxWeightKg()).isEqualTo(95.0);
        assertThat(ep.lastSession().date()).isEqualTo("2026-03-17");
        assertThat(ep.lastSession().maxWeightKg()).isEqualTo(100.0);
    }

    @Test
    void getProgress_throwsOnMissingUserId() {
        assertThatThrownBy(() -> service.getProgress(null, "2026-03-01", "2026-03-17", null))
                .isInstanceOf(InvalidRequestException.class);
    }

    @Test
    void getProgress_throwsWhenFromAfterTo() {
        assertThatThrownBy(() -> service.getProgress("usr-1", "2026-03-17", "2026-03-01", null))
                .isInstanceOf(InvalidRequestException.class)
                .hasMessageContaining("from");
    }

    @Test
    void getProgress_totalWorkouts_filteredByExerciseId() {
        // Session 1: contains ex-001 only
        service.logWorkout(new WorkoutRequest("usr-1", "2026-03-01", 45,
                List.of(new WorkoutSet("ex-001", 8, 95.0, 1)), null));
        // Session 2: contains ex-001 and ex-002
        service.logWorkout(new WorkoutRequest("usr-1", "2026-03-10", 50,
                List.of(new WorkoutSet("ex-001", 8, 100.0, 1),
                        new WorkoutSet("ex-002", 10, 80.0, 1)), null));
        // Session 3: contains ex-002 only
        service.logWorkout(new WorkoutRequest("usr-1", "2026-03-17", 40,
                List.of(new WorkoutSet("ex-002", 10, 85.0, 1)), null));

        ProgressResponse progress = service.getProgress("usr-1", "2026-03-01", "2026-03-31", "ex-001");

        // Only sessions 1 and 2 contain ex-001
        assertThat(progress.totalWorkouts()).isEqualTo(2);
    }

    @Test
    void getProgress_filtersOtherUsers() {
        service.logWorkout(new WorkoutRequest("usr-A", "2026-03-10", 30,
                List.of(new WorkoutSet("ex-002", 10, 80.0, 1)), null));

        ProgressResponse progress = service.getProgress("usr-B", "2026-03-01", "2026-03-31", null);

        assertThat(progress.totalWorkouts()).isEqualTo(0);
        assertThat(progress.exerciseProgress()).isEmpty();
    }
}
