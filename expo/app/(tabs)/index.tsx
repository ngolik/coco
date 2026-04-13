/**
 * Tab 1 — Plan
 *
 * - Form: Bench Press 1RM, Squat 1RM, Deadlift 1RM (kg)
 * - Generate Plan button
 * - 4 microcycles shown as collapsible sections
 * - Each microcycle lists training days → exercises → sets × reps × weight
 * - Completed days marked with a checkmark icon
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
  Alert,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useWorkoutPlan } from '../../src/hooks/useWorkoutPlan';
import { ExerciseTable } from '../../src/components/ExerciseTable';

export default function PlanTab() {
  const { profile, plan, completedWorkouts, loading, generate } = useWorkoutPlan();

  const [bench, setBench] = useState(profile ? String(profile.benchPress1rm) : '');
  const [squat, setSquat] = useState(profile ? String(profile.squat1rm) : '');
  const [deadlift, setDeadlift] = useState(profile ? String(profile.deadlift1rm) : '');
  const [generating, setGenerating] = useState(false);
  const [expandedMc, setExpandedMc] = useState<number | null>(1);

  // Sync form when profile loads
  React.useEffect(() => {
    if (profile && !bench) {
      setBench(String(profile.benchPress1rm));
      setSquat(String(profile.squat1rm));
      setDeadlift(String(profile.deadlift1rm));
    }
  }, [profile]);

  const handleGenerate = async () => {
    const b = parseFloat(bench);
    const s = parseFloat(squat);
    const d = parseFloat(deadlift);
    if (!b || !s || !d || b <= 0 || s <= 0 || d <= 0) {
      Alert.alert('Invalid input', 'Enter positive values for all 1RM fields.');
      return;
    }
    setGenerating(true);
    try {
      await generate(b, s, d);
      setExpandedMc(1);
    } catch (e) {
      Alert.alert('Error', e instanceof Error ? e.message : 'Failed to generate plan');
    } finally {
      setGenerating(false);
    }
  };

  const isDayCompleted = (mcNumber: number, dayNumber: number) =>
    completedWorkouts.some((w) => w.microcycle === mcNumber && w.day === dayNumber);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color="#2563EB" />
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* ── 1RM Form ── */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Enter your 1RM (kg)</Text>

        <View style={styles.inputRow}>
          <Text style={styles.label}>Bench Press</Text>
          <TextInput
            style={styles.input}
            value={bench}
            onChangeText={setBench}
            keyboardType="decimal-pad"
            placeholder="e.g. 100"
            accessibilityLabel="Bench Press one rep max in kilograms"
            returnKeyType="next"
          />
        </View>

        <View style={styles.inputRow}>
          <Text style={styles.label}>Squat</Text>
          <TextInput
            style={styles.input}
            value={squat}
            onChangeText={setSquat}
            keyboardType="decimal-pad"
            placeholder="e.g. 130"
            accessibilityLabel="Squat one rep max in kilograms"
            returnKeyType="next"
          />
        </View>

        <View style={styles.inputRow}>
          <Text style={styles.label}>Deadlift</Text>
          <TextInput
            style={styles.input}
            value={deadlift}
            onChangeText={setDeadlift}
            keyboardType="decimal-pad"
            placeholder="e.g. 160"
            accessibilityLabel="Deadlift one rep max in kilograms"
            returnKeyType="done"
          />
        </View>

        <TouchableOpacity
          style={[styles.button, generating && styles.buttonDisabled]}
          onPress={handleGenerate}
          disabled={generating}
          accessibilityRole="button"
          accessibilityLabel="Generate workout plan"
        >
          {generating ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.buttonText}>Generate Plan</Text>
          )}
        </TouchableOpacity>
      </View>

      {/* ── Microcycles ── */}
      {plan && plan.map((mc) => (
        <View key={mc.microcycleNumber} style={styles.card}>
          {/* Accordion header */}
          <TouchableOpacity
            style={styles.mcHeader}
            onPress={() =>
              setExpandedMc(expandedMc === mc.microcycleNumber ? null : mc.microcycleNumber)
            }
            accessibilityRole="button"
            accessibilityLabel={`Microcycle ${mc.microcycleNumber}`}
            accessibilityState={{ expanded: expandedMc === mc.microcycleNumber }}
          >
            <Text style={styles.mcTitle}>Microcycle {mc.microcycleNumber}</Text>
            <Ionicons
              name={expandedMc === mc.microcycleNumber ? 'chevron-up' : 'chevron-down'}
              size={20}
              color="#6B7280"
            />
          </TouchableOpacity>

          {/* Accordion body */}
          {expandedMc === mc.microcycleNumber && (
            <View>
              {mc.days.map((day) => {
                const completed = isDayCompleted(mc.microcycleNumber, day.dayNumber);
                return (
                  <View key={day.dayNumber} style={styles.daySection}>
                    <View style={styles.dayHeader}>
                      <Text style={styles.dayTitle}>
                        {day.isRestDay ? `Day ${day.dayNumber} — Rest` : `Day ${day.dayNumber}`}
                      </Text>
                      {completed && (
                        <Ionicons
                          name="checkmark-circle"
                          size={20}
                          color="#10B981"
                          accessibilityLabel="Completed"
                        />
                      )}
                    </View>

                    {day.isRestDay ? (
                      <Text style={styles.restText}>Recovery day — no training</Text>
                    ) : (
                      day.exercises.map((ex, idx) => (
                        <ExerciseTable key={idx} exercise={ex} />
                      ))
                    )}
                  </View>
                );
              })}
            </View>
          )}
        </View>
      ))}

      {!plan && (
        <View style={styles.emptyState}>
          <Ionicons name="barbell-outline" size={48} color="#D1D5DB" />
          <Text style={styles.emptyText}>Enter your 1RM values above to generate a plan</Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F9FAFB' },
  content: { padding: 16, paddingBottom: 40 },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
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
  cardTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#111827',
    marginBottom: 12,
  },
  inputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  label: {
    width: 110,
    fontSize: 14,
    color: '#374151',
    fontWeight: '500',
  },
  input: {
    flex: 1,
    height: 42,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 8,
    paddingHorizontal: 12,
    fontSize: 15,
    color: '#111827',
    backgroundColor: '#F9FAFB',
  },
  button: {
    backgroundColor: '#2563EB',
    borderRadius: 10,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: { opacity: 0.6 },
  buttonText: { color: '#FFFFFF', fontWeight: '700', fontSize: 15 },
  mcHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  mcTitle: { fontSize: 15, fontWeight: '700', color: '#1F2937' },
  daySection: {
    marginTop: 14,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#E5E7EB',
    paddingTop: 12,
  },
  dayHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  dayTitle: { fontSize: 13, fontWeight: '600', color: '#6B7280', textTransform: 'uppercase' },
  restText: { fontSize: 13, color: '#9CA3AF', fontStyle: 'italic' },
  emptyState: { alignItems: 'center', marginTop: 60, gap: 12 },
  emptyText: { fontSize: 14, color: '#9CA3AF', textAlign: 'center', maxWidth: 240 },
});
