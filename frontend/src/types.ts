export interface WorkoutPlanRequest {
  bench_press_1rm: number
  squat_1rm: number
  deadlift_1rm: number
}

export interface ExerciseSet {
  reps: number
  weight_kg: number
}

export interface Exercise {
  name: string
  sets: ExerciseSet[]
}

export interface TrainingDay {
  day: number
  exercises: Exercise[]
}

export interface Microcycle {
  microcycle: number
  days: TrainingDay[]
}

export type WorkoutPlanResponse = Microcycle[]
