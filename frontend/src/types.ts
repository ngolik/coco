export type ExerciseType = 'single-joint' | 'multi-joint'

export interface WorkoutPlanRequest {
  exercise_name: string
  one_rm_kg: number
  target_intensity_pct: number
  num_sets: number
  reps_per_set: number
  exercise_type: ExerciseType
}

export interface WorkoutSet {
  set_number: number
  working_weight_kg: number
  reps: number
  rest_time_sec: number
}

export interface WorkoutPlanResponse {
  sets: WorkoutSet[]
}

export interface ApiError {
  error: string
  code: number
}
