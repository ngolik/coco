/**
 * Local persistence layer using AsyncStorage.
 *
 * Schema:
 *   userProfile      → UserProfile JSON
 *   cachedPlan       → Microcycle[] JSON
 *   completedWorkouts → CompletedWorkout[] JSON
 */

import AsyncStorage from '@react-native-async-storage/async-storage';
import type { UserProfile, Microcycle, CompletedWorkout } from '../data/types';

const KEYS = {
  USER_PROFILE: 'userProfile',
  CACHED_PLAN: 'cachedPlan',
  COMPLETED_WORKOUTS: 'completedWorkouts',
} as const;

// ── User Profile ──────────────────────────────────────────────────────────────

export async function loadUserProfile(): Promise<UserProfile | null> {
  const raw = await AsyncStorage.getItem(KEYS.USER_PROFILE);
  return raw ? (JSON.parse(raw) as UserProfile) : null;
}

export async function saveUserProfile(profile: UserProfile): Promise<void> {
  await AsyncStorage.setItem(KEYS.USER_PROFILE, JSON.stringify(profile));
}

// ── Cached Plan ───────────────────────────────────────────────────────────────

export async function loadCachedPlan(): Promise<Microcycle[] | null> {
  const raw = await AsyncStorage.getItem(KEYS.CACHED_PLAN);
  return raw ? (JSON.parse(raw) as Microcycle[]) : null;
}

export async function saveCachedPlan(plan: Microcycle[]): Promise<void> {
  await AsyncStorage.setItem(KEYS.CACHED_PLAN, JSON.stringify(plan));
}

// ── Completed Workouts ────────────────────────────────────────────────────────

export async function loadCompletedWorkouts(): Promise<CompletedWorkout[]> {
  const raw = await AsyncStorage.getItem(KEYS.COMPLETED_WORKOUTS);
  return raw ? (JSON.parse(raw) as CompletedWorkout[]) : [];
}

export async function saveCompletedWorkout(workout: CompletedWorkout): Promise<void> {
  const existing = await loadCompletedWorkouts();
  const updated = [...existing, workout];
  await AsyncStorage.setItem(KEYS.COMPLETED_WORKOUTS, JSON.stringify(updated));
}

export async function clearAllData(): Promise<void> {
  await AsyncStorage.multiRemove([
    KEYS.USER_PROFILE,
    KEYS.CACHED_PLAN,
    KEYS.COMPLETED_WORKOUTS,
  ]);
}
