import { useState, FormEvent } from 'react'
import type { WorkoutPlanRequest } from '../types'
import styles from './WorkoutForm.module.css'

interface WorkoutFormProps {
  onSubmit: (data: WorkoutPlanRequest) => void
  loading: boolean
}

interface FormErrors {
  bench_press_1rm?: string
  squat_1rm?: string
  deadlift_1rm?: string
}

export function WorkoutForm({ onSubmit, loading }: WorkoutFormProps) {
  const [benchPress, setBenchPress] = useState('')
  const [squat, setSquat] = useState('')
  const [deadlift, setDeadlift] = useState('')
  const [errors, setErrors] = useState<FormErrors>({})

  function validate(): boolean {
    const next: FormErrors = {}

    const benchNum = Number(benchPress)
    if (!benchPress || isNaN(benchNum) || benchNum < 1) {
      next.bench_press_1rm = 'Must be at least 1 kg'
    }

    const squatNum = Number(squat)
    if (!squat || isNaN(squatNum) || squatNum < 1) {
      next.squat_1rm = 'Must be at least 1 kg'
    }

    const deadliftNum = Number(deadlift)
    if (!deadlift || isNaN(deadliftNum) || deadliftNum < 1) {
      next.deadlift_1rm = 'Must be at least 1 kg'
    }

    setErrors(next)
    return Object.keys(next).length === 0
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    if (!validate()) return

    onSubmit({
      bench_press_1rm: Number(benchPress),
      squat_1rm: Number(squat),
      deadlift_1rm: Number(deadlift),
    })
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>
      <div className={styles.field}>
        <label htmlFor="bench-press">Жим лежа / Bench Press 1RM (kg)</label>
        <input
          id="bench-press"
          type="number"
          min={1}
          value={benchPress}
          onChange={(e) => setBenchPress(e.target.value)}
          placeholder="e.g. 115"
          aria-describedby={errors.bench_press_1rm ? 'bench-press-error' : undefined}
          aria-invalid={!!errors.bench_press_1rm}
        />
        {errors.bench_press_1rm && (
          <span id="bench-press-error" className={styles.error} role="alert">
            {errors.bench_press_1rm}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="squat">Присед / Squat 1RM (kg)</label>
        <input
          id="squat"
          type="number"
          min={1}
          value={squat}
          onChange={(e) => setSquat(e.target.value)}
          placeholder="e.g. 80"
          aria-describedby={errors.squat_1rm ? 'squat-error' : undefined}
          aria-invalid={!!errors.squat_1rm}
        />
        {errors.squat_1rm && (
          <span id="squat-error" className={styles.error} role="alert">
            {errors.squat_1rm}
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label htmlFor="deadlift">Становая тяга / Deadlift 1RM (kg)</label>
        <input
          id="deadlift"
          type="number"
          min={1}
          value={deadlift}
          onChange={(e) => setDeadlift(e.target.value)}
          placeholder="e.g. 140"
          aria-describedby={errors.deadlift_1rm ? 'deadlift-error' : undefined}
          aria-invalid={!!errors.deadlift_1rm}
        />
        {errors.deadlift_1rm && (
          <span id="deadlift-error" className={styles.error} role="alert">
            {errors.deadlift_1rm}
          </span>
        )}
      </div>

      <button type="submit" className={styles.submit} disabled={loading}>
        {loading ? 'Calculating…' : 'Calculate Plan'}
      </button>
    </form>
  )
}
