import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import type { ExerciseDetail } from '../data/types';

interface Props {
  exercise: ExerciseDetail;
  completedSets?: boolean[];
}

export function ExerciseTable({ exercise, completedSets }: Props) {
  return (
    <View style={styles.container}>
      <Text style={styles.name}>{exercise.name}</Text>
      <View style={styles.headerRow}>
        <Text style={[styles.cell, styles.header, styles.setCol]}>#</Text>
        <Text style={[styles.cell, styles.header, styles.repsCol]}>Reps</Text>
        <Text style={[styles.cell, styles.header, styles.weightCol]}>kg</Text>
        {completedSets && (
          <Text style={[styles.cell, styles.header, styles.doneCol]}>Done</Text>
        )}
      </View>
      {exercise.sets.map((set, idx) => {
        const done = completedSets?.[idx] ?? false;
        return (
          <View
            key={idx}
            style={[styles.row, done && styles.rowDone, idx % 2 === 0 && styles.rowAlt]}
          >
            <Text style={[styles.cell, styles.setCol]}>{idx + 1}</Text>
            <Text style={[styles.cell, styles.repsCol]}>{set.reps}</Text>
            <Text style={[styles.cell, styles.weightCol]}>{set.weight}</Text>
            {completedSets && (
              <Text style={[styles.cell, styles.doneCol]}>{done ? '✓' : ''}</Text>
            )}
          </View>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { marginBottom: 12 },
  name: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1F2937',
    marginBottom: 4,
  },
  headerRow: {
    flexDirection: 'row',
    backgroundColor: '#F3F4F6',
    borderRadius: 4,
    paddingVertical: 4,
  },
  row: {
    flexDirection: 'row',
    paddingVertical: 4,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#E5E7EB',
  },
  rowAlt: { backgroundColor: '#FAFAFA' },
  rowDone: { opacity: 0.5 },
  cell: { fontSize: 13, color: '#374151', textAlign: 'center' },
  header: { fontWeight: '700', color: '#6B7280', fontSize: 11 },
  setCol: { width: 30 },
  repsCol: { flex: 1 },
  weightCol: { flex: 1 },
  doneCol: { width: 40, color: '#10B981', fontWeight: '700' },
});
