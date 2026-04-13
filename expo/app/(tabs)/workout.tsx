/**
 * Tab 2 — Workout
 *
 * - Shows next scheduled workout based on saved progress
 * - Start button begins the active workout
 * - Active workout: list of exercises, each set is a pressable row to mark complete
 * - Rest timer countdown between sets
 * - Finish button saves workout to local storage
 */

import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Platform,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWorkoutPlan } from '../../src/hooks/useWorkoutPlan';
import { useRestTimer } from '../../src/hooks/useRestTimer';
import type { CompletedWorkout } from '../../src/data/types';

type WorkoutState = 'idle' | 'active' | 'done';

export default function WorkoutTab() {
  const { plan, completedWorkouts, loading, completeWorkout, nextWorkout } = useWorkoutPlan();
  const { remaining, running, start: startTimer, stop: stopTimer } = useRestTimer(90);

  const [state, setState] = useState<WorkoutState>('idle');
  // completedSets[exerciseIdx][setIdx] = boolean
  const [completedSets, setCompletedSets] = useState<boolean[][]>([]);

  const next = nextWorkout();

  const activeDay = (() => {
    if (!plan || !next) return null;
    const mc = plan.find((m) => m.microcycleNumber === next.microcycle);
    return mc?.days.find((d) => d.dayNumber === next.day) ?? null;
  })();

  const handleStart = () => {
    if (!activeDay) return;
    const initial = activeDay.exercises.map((ex) =>
      ex.sets.map(() => false),
    );
    setCompletedSets(initial);
    setState('active');
    stopTimer();
  };

  const handleToggleSet = useCallback(
    (exIdx: number, setIdx: number) => {
      setCompletedSets((prev) => {
        const copy = prev.map((row) => [...row]);
        const wasCompleted = copy[exIdx][setIdx];
        copy[exIdx][setIdx] = !wasCompleted;
        // Start rest timer when marking complete
        if (!wasCompleted) startTimer(90);
        return copy;
      });
    },
    [startTimer],
  );

  const handleFinish = async () => {
    if (!activeDay || !next) return;

    Alert.alert('Finish Workout?', 'This will save your workout to history.', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Finish',
        style: 'default',
        onPress: async () => {
          const workout: CompletedWorkout = {
            id: `${next.microcycle}-${next.day}-${Date.now()}`,
            date: new Date().toISOString(),
            microcycle: next.microcycle,
            day: next.day,
            exercises: activeDay.exercises.map((ex, exIdx) => ({
              name: ex.name,
              completedSets: completedSets[exIdx] ?? [],
            })),
          };
          await completeWorkout(workout);
          stopTimer();
          setState('done');
        },
      },
    ]);
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#2563EB" />
      </View>
    );
  }

  if (!plan) {
    return (
      <View style={styles.center}>
        <Ionicons name="barbell-outline" size={48} color="#D1D5DB" />
        <Text style={styles.emptyText}>Generate a plan in the Plan tab first</Text>
      </View>
    );
  }

  if (state === 'done') {
    return (
      <View style={styles.center}>
        <Ionicons name="checkmark-circle" size={64} color="#10B981" />
        <Text style={styles.doneTitle}>Workout Complete!</Text>
        <Text style={styles.doneSubtitle}>Saved to history</Text>
        <TouchableOpacity style={styles.button} onPress={() => setState('idle')}>
          <Text style={styles.buttonText}>Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  if (!next) {
    return (
      <View style={styles.center}>
        <Ionicons name="trophy" size={48} color="#F59E0B" />
        <Text style={styles.doneTitle}>Program Complete!</Text>
        <Text style={styles.doneSubtitle}>All 4 microcycles finished. Generate a new plan.</Text>
      </View>
    );
  }

  // ── Idle state: show next workout preview ──────────────────────────────────
  if (state === 'idle') {
    return (
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <View style={styles.card}>
          <Text style={styles.sectionLabel}>NEXT WORKOUT</Text>
          <Text style={styles.workoutTitle}>
            Microcycle {next.microcycle} · Day {next.day}
          </Text>
          {activeDay && (
            <View style={styles.previewList}>
              {activeDay.exercises.map((ex, idx) => (
                <Text key={idx} style={styles.previewExercise}>
                  · {ex.name} — {ex.sets.length} sets
                </Text>
              ))}
            </View>
          )}
          <TouchableOpacity
            style={styles.button}
            onPress={handleStart}
            accessibilityRole="button"
            accessibilityLabel="Start workout"
          >
            <Ionicons name="play" size={18} color="#FFFFFF" style={{ marginRight: 6 }} />
            <Text style={styles.buttonText}>Start Workout</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    );
  }

  // ── Active workout ─────────────────────────────────────────────────────────
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Rest timer banner */}
      {running && (
        <View style={styles.timerBanner}>
          <Ionicons name="timer-outline" size={18} color="#FFFFFF" />
          <Text style={styles.timerText}>Rest: {remaining}s</Text>
          <TouchableOpacity onPress={stopTimer} accessibilityLabel="Skip rest timer">
            <Ionicons name="close-circle" size={20} color="#FFFFFF" />
          </TouchableOpacity>
        </View>
      )}

      <Text style={styles.workoutTitle}>
        Microcycle {next.microcycle} · Day {next.day}
      </Text>

      {activeDay?.exercises.map((ex, exIdx) => (
        <View key={exIdx} style={styles.card}>
          <Text style={styles.exerciseName}>{ex.name}</Text>
          <View style={styles.tableHeader}>
            <Text style={[styles.col, styles.colSet, styles.headerText]}>#</Text>
            <Text style={[styles.col, styles.colReps, styles.headerText]}>Reps</Text>
            <Text style={[styles.col, styles.colWeight, styles.headerText]}>kg</Text>
            <Text style={[styles.col, styles.colDone, styles.headerText]}>Done</Text>
          </View>
          {ex.sets.map((set, setIdx) => {
            const done = completedSets[exIdx]?.[setIdx] ?? false;
            return (
              <TouchableOpacity
                key={setIdx}
                style={[styles.setRow, done && styles.setRowDone, setIdx % 2 === 0 && styles.setRowAlt]}
                onPress={() => handleToggleSet(exIdx, setIdx)}
                accessibilityRole="checkbox"
                accessibilityState={{ checked: done }}
                accessibilityLabel={`Set ${setIdx + 1}: ${set.reps} reps at ${set.weight} kg`}
              >
                <Text style={[styles.col, styles.colSet]}>{setIdx + 1}</Text>
                <Text style={[styles.col, styles.colReps]}>{set.reps}</Text>
                <Text style={[styles.col, styles.colWeight]}>{set.weight}</Text>
                <View style={[styles.col, styles.colDone]}>
                  {done ? (
                    <Ionicons name="checkmark-circle" size={20} color="#10B981" />
                  ) : (
                    <View style={styles.emptyCheck} />
                  )}
                </View>
              </TouchableOpacity>
            );
          })}
        </View>
      ))}

      <TouchableOpacity
        style={[styles.button, styles.finishButton]}
        onPress={handleFinish}
        accessibilityRole="button"
        accessibilityLabel="Finish workout"
      >
        <Ionicons name="checkmark" size={18} color="#FFFFFF" style={{ marginRight: 6 }} />
        <Text style={styles.buttonText}>Finish Workout</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB' },
  content: { padding: 16, paddingBottom: 40 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: 12, padding: 24 },
  emptyText: { fontSize: 14, color: '#9CA3AF', textAlign: 'center', maxWidth: 240 },
  doneTitle: { fontSize: 22, fontWeight: '700', color: '#111827' },
  doneSubtitle: { fontSize: 14, color: '#6B7280', textAlign: 'center' },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.06,
        shadowRadius: 4,
      },
      android: { elevation: 2 },
    }),
  },
  sectionLabel: {
    fontSize: 11,
    fontWeight: '700',
    color: '#9CA3AF',
    letterSpacing: 0.8,
    marginBottom: 4,
  },
  workoutTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#111827',
    marginBottom: 12,
  },
  previewList: { marginBottom: 16 },
  previewExercise: { fontSize: 14, color: '#374151', marginBottom: 4 },
  button: {
    backgroundColor: '#2563EB',
    borderRadius: 10,
    height: 48,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  finishButton: { backgroundColor: '#10B981', marginTop: 8 },
  buttonText: { color: '#FFFFFF', fontWeight: '700', fontSize: 15 },
  timerBanner: {
    backgroundColor: '#2563EB',
    borderRadius: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 12,
    marginBottom: 12,
    gap: 8,
  },
  timerText: { flex: 1, color: '#FFFFFF', fontWeight: '700', fontSize: 16, marginLeft: 8 },
  exerciseName: { fontSize: 15, fontWeight: '600', color: '#1F2937', marginBottom: 8 },
  tableHeader: {
    flexDirection: 'row',
    paddingBottom: 4,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
    marginBottom: 2,
  },
  headerText: { color: '#9CA3AF', fontSize: 11, fontWeight: '700', textTransform: 'uppercase' },
  setRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 8,
    borderRadius: 6,
  },
  setRowAlt: { backgroundColor: '#F9FAFB' },
  setRowDone: { opacity: 0.5 },
  col: { fontSize: 14, color: '#374151', textAlign: 'center' },
  colSet: { width: 30 },
  colReps: { flex: 1 },
  colWeight: { flex: 1 },
  colDone: { width: 40, alignItems: 'center' },
  emptyCheck: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: '#D1D5DB',
  },
});
