import { render, screen } from '@testing-library/react'
import { WorkoutTable } from '../components/WorkoutTable'
import type { WorkoutSet } from '../types'
import { describe, it, expect } from 'vitest'

const mockSets: WorkoutSet[] = [
  { set_number: 1, working_weight_kg: 75.0, reps: 5, rest_time_sec: 120 },
  { set_number: 2, working_weight_kg: 75.0, reps: 5, rest_time_sec: 120 },
  { set_number: 3, working_weight_kg: 75.0, reps: 5, rest_time_sec: 180 },
]

describe('WorkoutTable', () => {
  it('renders all set rows', () => {
    render(<WorkoutTable sets={mockSets} exerciseName="Back Squat" />)
    expect(screen.getAllByRole('row')).toHaveLength(4) // header + 3 rows
  })

  it('displays exercise name in heading', () => {
    render(<WorkoutTable sets={mockSets} exerciseName="Deadlift" />)
    expect(screen.getByText(/deadlift/i)).toBeInTheDocument()
  })

  it('formats rest time in minutes when >= 60s', () => {
    render(<WorkoutTable sets={mockSets} exerciseName="Squat" />)
    expect(screen.getAllByText('2m')).toHaveLength(2)
    expect(screen.getByText('3m')).toBeInTheDocument()
  })
})
