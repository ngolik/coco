import type { WorkoutSet } from '../types'
import styles from './WorkoutTable.module.css'

interface WorkoutTableProps {
  sets: WorkoutSet[]
  exerciseName: string
}

export function WorkoutTable({ sets, exerciseName }: WorkoutTableProps) {
  return (
    <section aria-label="Workout plan results" className={styles.section}>
      <h2 className={styles.title}>{exerciseName} — Workout Plan</h2>
      <div className={styles.tableWrapper}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th scope="col">Set #</th>
              <th scope="col">Working Weight (kg)</th>
              <th scope="col">Reps</th>
              <th scope="col">Rest Time</th>
            </tr>
          </thead>
          <tbody>
            {sets.map((s) => (
              <tr key={s.set_number}>
                <td>{s.set_number}</td>
                <td>{s.working_weight_kg.toFixed(1)}</td>
                <td>{s.reps}</td>
                <td>{formatRest(s.rest_time_sec)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  )
}

function formatRest(seconds: number): string {
  if (seconds < 60) return `${seconds}s`
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return s === 0 ? `${m}m` : `${m}m ${s}s`
}
