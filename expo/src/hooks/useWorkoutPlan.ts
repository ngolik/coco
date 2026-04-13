import { useState, useEffect, useCallback } from 'react';
import { generatePlan } from '../utils/workoutPlan';
import {
  loadUserProfile,
  saveUserProfile,
  loadCachedPlan,
  saveCachedPlan,
  loadCompletedWorkouts,
  saveCompletedWorkout,
} from '../storage/storage';
import type { UserProfile, Microcycle, CompletedWorkout } from '../data/types';

export function useWorkoutPlan() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [plan, setPlan] = useState<Microcycle[] | null>(null);
  const [completedWorkouts, setCompletedWorkouts] = useState<CompletedWorkout[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Load persisted data on mount
  useEffect(() => {
    (async () => {
      try {
        const [savedProfile, savedPlan, savedWorkouts] = await Promise.all([
          loadUserProfile(),
          loadCachedPlan(),
          loadCompletedWorkouts(),
        ]);
        if (savedProfile) setProfile(savedProfile);
        if (savedPlan) setPlan(savedPlan);
        setCompletedWorkouts(savedWorkouts);
      } catch (e) {
        setError('Failed to load data');
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const generate = useCallback(
    async (bench: number, squat: number, deadlift: number) => {
      setError(null);
      try {
        const newProfile: UserProfile = { benchPress1rm: bench, squat1rm: squat, deadlift1rm: deadlift };
        const newPlan = generatePlan(bench, squat, deadlift);
        await Promise.all([saveUserProfile(newProfile), saveCachedPlan(newPlan)]);
        setProfile(newProfile);
        setPlan(newPlan);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Plan generation failed');
        throw e;
      }
    },
    [],
  );

  const completeWorkout = useCallback(async (workout: CompletedWorkout) => {
    await saveCompletedWorkout(workout);
    setCompletedWorkouts((prev) => [...prev, workout]);
  }, []);

  /**
   * Returns the next unfinished (microcycle, day) pair based on completed workouts.
   * Returns null if the whole program is done.
   */
  const nextWorkout = useCallback((): { microcycle: number; day: number } | null => {
    if (!plan) return null;

    for (const mc of plan) {
      for (const day of mc.days) {
        if (day.isRestDay) continue;
        const done = completedWorkouts.some(
          (w) => w.microcycle === mc.microcycleNumber && w.day === day.dayNumber,
        );
        if (!done) {
          return { microcycle: mc.microcycleNumber, day: day.dayNumber };
        }
      }
    }
    return null; // All workouts complete
  }, [plan, completedWorkouts]);

  return {
    profile,
    plan,
    completedWorkouts,
    loading,
    error,
    generate,
    completeWorkout,
    nextWorkout,
  };
}
