export interface WorkoutPlanRequest {
  bench_press_1rm: number
  squat_1rm: number
  deadlift_1rm: number
}

export interface ExerciseSet {
  set_number: number
  reps: number
  weight_kg: number
}

export interface Exercise {
  name: string
  sets: ExerciseSet[]
}

export interface TrainingDay {
  day_number: number
  exercises: Exercise[]
}

export interface Microcycle {
  microcycle_number: number
  days: TrainingDay[]
}

export interface WorkoutPlanResponse {
  microcycles: Microcycle[]
}

export interface ApiError {
  error: string
  code: number
}
