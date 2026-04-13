// ── Program template types ──────────────────────────────────────────────────

export interface SetTemplate {
  numSets: number;
  reps: number;
  pct: number;
}

export interface ExerciseTemplate {
  name: string;
  setGroups: SetTemplate[];
}

export interface DayTemplate {
  exercises: ExerciseTemplate[];
}

export interface ProgramMicrocycle {
  days: DayTemplate[];
}

// ── Generated plan types ────────────────────────────────────────────────────

export interface SetDetail {
  reps: number;
  weight: number; // kg, rounded to nearest 2.5
}

export interface ExerciseDetail {
  name: string;
  sets: SetDetail[];
}

export interface TrainingDay {
  dayNumber: number;
  exercises: ExerciseDetail[];
  isRestDay: boolean;
}

export interface Microcycle {
  microcycleNumber: number;
  days: TrainingDay[];
}

// ── Persistence types ────────────────────────────────────────────────────────

export interface UserProfile {
  benchPress1rm: number;
  squat1rm: number;
  deadlift1rm: number;
}

export interface CompletedSet {
  reps: number;
  weight: number;
  completed: boolean;
}

export interface CompletedExercise {
  name: string;
  completedSets: boolean[];
}

export interface CompletedWorkout {
  id: string;
  date: string; // ISO date string
  microcycle: number;
  day: number;
  exercises: CompletedExercise[];
}
