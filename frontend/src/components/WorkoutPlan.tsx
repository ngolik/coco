import { useState } from 'react'
import type { WorkoutPlanResponse } from '../types'
import styles from './WorkoutPlan.module.css'

interface WorkoutPlanProps {
  plan: WorkoutPlanResponse
}

export function WorkoutPlan({ plan }: WorkoutPlanProps) {
  const [activeIdx, setActiveIdx] = useState(0)
  const microcycle = plan[activeIdx]

  return (
    <section aria-label="Workout plan results" className={styles.section}>
      <div className={styles.tabs} role="tablist" aria-label="Microcycles">
        {plan.map((mc, idx) => (
          <button
            key={mc.microcycle}
            role="tab"
            aria-selected={idx === activeIdx}
            aria-controls={`panel-${idx}`}
            id={`tab-${idx}`}
            className={`${styles.tab} ${idx === activeIdx ? styles.tabActive : ''}`}
            onClick={() => setActiveIdx(idx)}
          >
            Microcycle {mc.microcycle}
          </button>
        ))}
      </div>

      <div
        id={`panel-${activeIdx}`}
        role="tabpanel"
        aria-labelledby={`tab-${activeIdx}`}
        className={styles.panel}
      >
        {microcycle.days.map((day) => (
          <div key={day.day} className={styles.day}>
            <h3 className={styles.dayTitle}>Day {day.day}</h3>
            <div className={styles.tableWrapper}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th scope="col">Exercise</th>
                    <th scope="col">Reps</th>
                    <th scope="col">Weight (kg)</th>
                  </tr>
                </thead>
                <tbody>
                  {day.exercises.flatMap((exercise, exIdx) =>
                    exercise.sets.map((set, setIdx) => (
                      <tr key={`${exIdx}-${setIdx}`}>
                        {setIdx === 0 && (
                          <td rowSpan={exercise.sets.length} className={styles.exerciseName}>
                            {exercise.name}
                          </td>
                        )}
                        <td>{set.reps}</td>
                        <td>
                          {Number.isInteger(set.weight_kg)
                            ? set.weight_kg
                            : set.weight_kg.toFixed(1)}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        ))}
      </div>
    </section>
  )
}
