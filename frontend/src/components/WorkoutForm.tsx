import { useState, FormEvent } from 'react'
import type { WorkoutPlanRequest, ExerciseType } from '../types'
import styles from './WorkoutForm.module.css'

interface WorkoutFormProps {
  onSubmit: (data: WorkoutPlanRequest) => void
  loading: boolean
}

interface FormErrors {
  exercise_name?: string
  one_rm_kg?: string
  target_intensity_pct?: string
  num_sets?: string
  reps_per_set?: string
}

export function WorkoutForm({ onSubmit, loading }: WorkoutFormProps) {
  const [exerciseName, setExerciseName] = useState('')
  const [oneRm, setOneRm] = useState('')
  const [intensity, setIntensity] = useState('')
  const [sets, setSets] = useState('')
  const [reps, setReps] = useState('')
  const [exerciseType, setExerciseType] = useState<ExerciseType>('multi-joint')
  const [errors, setErrors] = useState<FormErrors>({})

  function validate(): boolean {
    const next: FormErrors = {}

    if (!exerciseName.trim()) {
      next.exercise_name = 'Exercise name is required'
    }

    const oneRmNum = Number(oneRm)
    if (!oneRm || isNaN(oneRmNum) || oneRmNum < 1) {
      next.one_rm_kg = '1RM must be at least 1 kg'
    }

    const intensityNum = Number(intensity)
    if (!intensity || isNaN(intensityNum) || intensityNum < 30 || intensityNum > 100) {
      next.target_intensity_pct = 'Intensity must be between 30 and 100'
    }

    const setsNum = Number(sets)
    if (!sets || isNaN(setsNum) || setsNum < 3 || setsNum > 5) {
      next.num_sets = 'Number of sets must be between 3 and 5'
    }

    const repsNum = Number(reps)
    if (!reps || isNaN(repsNum) || repsNum < 1) {
      next.reps_per_set = 'Reps per set is required (min 1)'
    }

    setErrors(next)
    return Object.keys(next).length === 0
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!validate()) return

    onSubmit({
      exercise_name: exerciseName.trim(),
      one_rm_kg: Number(oneRm),
      target_intensity_pct: Number(intensity),
      num_sets: Number(sets),
      reps_per_set: Number(reps),
      exercise_type: exerciseType,
    })
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>
      <div className={styles.field}>
        <label htmlFor="exercise-name">Exercise name</label>
        <input
          id="exercise-name"
          type="text"
          value={exerciseName}
          onChange={(e) => setExerciseName(e.target.value)}
          placeholder="e.g. Back Squat"
          aria-describedby={errors.exercise_name ? 'exercise-name-error' : undefined}
          aria-invalid={!!errors.exercise_name}
        />
        {errors.exercise_name && (
          <span id="exercise-name-error" className={styles.error} role="alert">
            {errors.exercise_name}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="one-rm">1RM (kg)</label>
        <input
          id="one-rm"
          type="number"
          min={1}
          value={oneRm}
          onChange={(e) => setOneRm(e.target.value)}
          placeholder="e.g. 100"
          aria-describedby={errors.one_rm_kg ? 'one-rm-error' : undefined}
          aria-invalid={!!errors.one_rm_kg}
        />
        {errors.one_rm_kg && (
          <span id="one-rm-error" className={styles.error} role="alert">
            {errors.one_rm_kg}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="intensity">Target intensity (%)</label>
        <input
          id="intensity"
          type="number"
          min={30}
          max={100}
          value={intensity}
          onChange={(e) => setIntensity(e.target.value)}
          placeholder="30–100"
          aria-describedby={errors.target_intensity_pct ? 'intensity-error' : undefined}
          aria-invalid={!!errors.target_intensity_pct}
        />
        {errors.target_intensity_pct && (
          <span id="intensity-error" className={styles.error} role="alert">
            {errors.target_intensity_pct}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="sets">Number of sets</label>
        <input
          id="sets"
          type="number"
          min={3}
          max={5}
          value={sets}
          onChange={(e) => setSets(e.target.value)}
          placeholder="3–5"
          aria-describedby={errors.num_sets ? 'sets-error' : undefined}
          aria-invalid={!!errors.num_sets}
        />
        {errors.num_sets && (
          <span id="sets-error" className={styles.error} role="alert">
            {errors.num_sets}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="reps">Reps per set</label>
        <input
          id="reps"
          type="number"
          min={1}
          value={reps}
          onChange={(e) => setReps(e.target.value)}
          placeholder="e.g. 5"
          aria-describedby={errors.reps_per_set ? 'reps-error' : undefined}
          aria-invalid={!!errors.reps_per_set}
        />
        {errors.reps_per_set && (
          <span id="reps-error" className={styles.error} role="alert">
            {errors.reps_per_set}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="exercise-type">Exercise type</label>
        <select
          id="exercise-type"
          value={exerciseType}
          onChange={(e) => setExerciseType(e.target.value as ExerciseType)}
        >
          <option value="multi-joint">Multi-joint</option>
          <option value="single-joint">Single-joint</option>
        </select>
      </div>

      <button type="submit" className={styles.submit} disabled={loading}>
        {loading ? 'Generating…' : 'Generate Plan'}
      </button>
    </form>
  )
}
