import { useState } from 'react'
import { WorkoutForm } from './components/WorkoutForm'
import { WorkoutPlan } from './components/WorkoutPlan'
import type { WorkoutPlanRequest, WorkoutPlanResponse } from './types'
import styles from './App.module.css'

const API_BASE = import.meta.env.VITE_API_BASE ?? ''

export function App() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [plan, setPlan] = useState<WorkoutPlanResponse | null>(null)

  async function handleSubmit(data: WorkoutPlanRequest) {
    setLoading(true)
    setError(null)
    setPlan(null)

    try {
      const response = await fetch(`${API_BASE}/api/workout/plan`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })

      if (!response.ok) {
        let message = `Request failed with status ${response.status}`
        try {
          const body = (await response.json()) as { error?: string }
          if (body.error) message = body.error
        } catch {
          // keep default message
        }
        setError(message)
        return
      }

      const result = (await response.json()) as WorkoutPlanResponse
      setPlan(result)
    } catch {
      setError('Network error — make sure the backend is running')
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className={styles.main}>
      <header className={styles.header}>
        <h1>Workout Plan Generator</h1>
      </header>

      <WorkoutForm onSubmit={handleSubmit} loading={loading} />

      {loading && (
        <p className={styles.loading} role="status" aria-live="polite">
          Calculating your workout plan…
        </p>
      )}

      {error && (
        <p className={styles.errorBanner} role="alert">
          {error}
        </p>
      )}

      {plan && <WorkoutPlan plan={plan} />}
    </main>
  )
}
