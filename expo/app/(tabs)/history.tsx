/**
 * Tab 3 — History
 *
 * - List of completed workouts by date
 * - Tap to see full detail (exercises + sets × reps × weight + completion status)
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWorkoutPlan } from '../../src/hooks/useWorkoutPlan';
import { ExerciseTable } from '../../src/components/ExerciseTable';
import type { CompletedWorkout } from '../../src/data/types';

export default function HistoryTab() {
  const { plan, completedWorkouts, loading } = useWorkoutPlan();
  const [selected, setSelected] = useState<CompletedWorkout | null>(null);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#2563EB" />
      </View>
    );
  }

  // ── Detail view ────────────────────────────────────────────────────────────
  if (selected) {
    // Look up the generated plan data for weights
    const mcPlan = plan?.find((m) => m.microcycleNumber === selected.microcycle);
    const dayPlan = mcPlan?.days.find((d) => d.dayNumber === selected.day);

    return (
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => setSelected(null)}
          accessibilityRole="button"
          accessibilityLabel="Back to history list"
        >
          <Ionicons name="arrow-back" size={18} color="#2563EB" />
          <Text style={styles.backText}>History</Text>
        </TouchableOpacity>

        <Text style={styles.detailTitle}>
          MC {selected.microcycle} · Day {selected.day}
        </Text>
        <Text style={styles.detailDate}>{formatDate(selected.date)}</Text>

        {selected.exercises.map((ex, exIdx) => {
          const planEx = dayPlan?.exercises[exIdx];
          if (!planEx) {
            return (
              <View key={exIdx} style={styles.card}>
                <Text style={styles.exerciseName}>{ex.name}</Text>
                <Text style={styles.setsCompleted}>
                  {ex.completedSets.filter(Boolean).length}/{ex.completedSets.length} sets completed
                </Text>
              </View>
            );
          }
          return (
            <View key={exIdx} style={styles.card}>
              <ExerciseTable exercise={planEx} completedSets={ex.completedSets} />
              <Text style={styles.setsCompleted}>
                {ex.completedSets.filter(Boolean).length}/{ex.completedSets.length} sets completed
              </Text>
            </View>
          );
        })}
      </ScrollView>
    );
  }

  // ── List view ──────────────────────────────────────────────────────────────
  if (completedWorkouts.length === 0) {
    return (
      <View style={styles.center}>
        <Ionicons name="time-outline" size={48} color="#D1D5DB" />
        <Text style={styles.emptyText}>No workouts completed yet</Text>
      </View>
    );
  }

  const sorted = [...completedWorkouts].sort(
    (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {sorted.map((workout) => {
        const totalSets = workout.exercises.reduce(
          (sum, ex) => sum + ex.completedSets.length,
          0,
        );
        const doneSets = workout.exercises.reduce(
          (sum, ex) => sum + ex.completedSets.filter(Boolean).length,
          0,
        );
        const allDone = doneSets === totalSets;

        return (
          <TouchableOpacity
            key={workout.id}
            style={styles.historyRow}
            onPress={() => setSelected(workout)}
            accessibilityRole="button"
            accessibilityLabel={`Workout on ${formatDate(workout.date)}, microcycle ${workout.microcycle} day ${workout.day}`}
          >
            <View style={styles.historyRowLeft}>
              <Ionicons
                name={allDone ? 'checkmark-circle' : 'checkmark-circle-outline'}
                size={22}
                color={allDone ? '#10B981' : '#9CA3AF'}
              />
              <View style={styles.historyRowInfo}>
                <Text style={styles.historyRowTitle}>
                  MC {workout.microcycle} · Day {workout.day}
                </Text>
                <Text style={styles.historyRowDate}>{formatDate(workout.date)}</Text>
              </View>
            </View>
            <View style={styles.historyRowRight}>
              <Text style={styles.historyRowSets}>
                {doneSets}/{totalSets} sets
              </Text>
              <Ionicons name="chevron-forward" size={16} color="#D1D5DB" />
            </View>
          </TouchableOpacity>
        );
      })}
    </ScrollView>
  );
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB' },
  content: { padding: 16, paddingBottom: 40 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: 12, padding: 24 },
  emptyText: { fontSize: 14, color: '#9CA3AF', textAlign: 'center', maxWidth: 240 },
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
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginBottom: 16,
  },
  backText: { color: '#2563EB', fontSize: 15, fontWeight: '500' },
  detailTitle: { fontSize: 22, fontWeight: '700', color: '#111827', marginBottom: 2 },
  detailDate: { fontSize: 13, color: '#9CA3AF', marginBottom: 16 },
  exerciseName: { fontSize: 15, fontWeight: '600', color: '#1F2937', marginBottom: 6 },
  setsCompleted: {
    fontSize: 12,
    color: '#9CA3AF',
    marginTop: 6,
    textAlign: 'right',
  },
  historyRow: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 14,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
      },
      android: { elevation: 1 },
    }),
  },
  historyRowLeft: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  historyRowInfo: {},
  historyRowTitle: { fontSize: 15, fontWeight: '600', color: '#1F2937' },
  historyRowDate: { fontSize: 12, color: '#9CA3AF', marginTop: 2 },
  historyRowRight: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  historyRowSets: { fontSize: 13, color: '#6B7280' },
});
