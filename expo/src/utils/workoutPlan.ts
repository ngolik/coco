/**
 * Workout plan generation logic.
 * Ported from WorkoutPlanService.java.
 *
 * Weight formula: round(oneRepMax * pct / 100 / 2.5) * 2.5
 */

import { PROGRAM } from '../data/program';
import type { Microcycle, ExerciseDetail, SetDetail, TrainingDay } from '../data/types';

/**
 * Returns the 1RM (kg) for the given exercise name.
 * For Молотковые сгибания, returns weight per dumbbell (bench / 6).
 */
export function exerciseOneRepMax(
  name: string,
  bench: number,
  squat: number,
  deadlift: number,
): number {
  switch (name) {
    case 'Жим лежа':            return bench;
    case 'Присед':               return squat;
    case 'Становая тяга':        return deadlift;
    case 'Жим стоя':             return bench * 0.60;
    case 'Жим средним хватом':   return bench * 0.90;
    case 'Бицепс стоя':          return bench * 0.40;
    case 'Молотковые сгибания':  return bench / 6.0;
    case 'Жим без ног':          return bench * 0.80;
    default:
      throw new Error(`Unknown exercise: ${name}`);
  }
}

/**
 * Calculates working weight: ROUND(1rm × pct/100 / 2.5) × 2.5
 */
export function workingWeight(oneRepMax: number, pct: number): number {
  return Math.round((oneRepMax * pct) / 100 / 2.5) * 2.5;
}

export function generatePlan(
  bench: number,
  squat: number,
  deadlift: number,
): Microcycle[] {
  if (bench <= 0 || squat <= 0 || deadlift <= 0) {
    throw new Error('All 1RM values must be positive');
  }

  return PROGRAM.map((mc, mcIdx) => {
    const days: TrainingDay[] = mc.days.map((dt, dayIdx) => {
      const exercises: ExerciseDetail[] = dt.exercises.map((et) => {
        const oneRm = exerciseOneRepMax(et.name, bench, squat, deadlift);
        const sets: SetDetail[] = et.setGroups.flatMap((sg) =>
          Array.from({ length: sg.numSets }, () => ({
            reps: sg.reps,
            weight: workingWeight(oneRm, sg.pct),
          })),
        );
        return { name: et.name, sets };
      });

      return {
        dayNumber: dayIdx + 1,
        exercises,
        isRestDay: dt.exercises.length === 0,
      };
    });

    return {
      microcycleNumber: mcIdx + 1,
      days,
    };
  });
}
