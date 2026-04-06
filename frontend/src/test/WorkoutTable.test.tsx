import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { WorkoutPlan } from '../components/WorkoutPlan'
import type { WorkoutPlanResponse } from '../types'
import { describe, it, expect } from 'vitest'

const mockPlan: WorkoutPlanResponse = {
  microcycles: [
    {
      microcycle_number: 1,
      days: [
        {
          day_number: 1,
          exercises: [
            {
              name: 'Bench Press',
              sets: [
                { set_number: 1, reps: 5, weight_kg: 85.0 },
                { set_number: 2, reps: 5, weight_kg: 87.5 },
              ],
            },
          ],
        },
      ],
    },
    {
      microcycle_number: 2,
      days: [
        {
          day_number: 1,
          exercises: [
            {
              name: 'Squat',
              sets: [{ set_number: 1, reps: 3, weight_kg: 70.0 }],
            },
          ],
        },
      ],
    },
  ],
}

describe('WorkoutPlan', () => {
  it('renders microcycle tabs', () => {
    render(<WorkoutPlan plan={mockPlan} />)
    expect(screen.getByRole('tab', { name: /week 1/i })).toBeInTheDocument()
    expect(screen.getByRole('tab', { name: /week 2/i })).toBeInTheDocument()
  })

  it('shows the first microcycle by default', () => {
    render(<WorkoutPlan plan={mockPlan} />)
    expect(screen.getByText('Bench Press')).toBeInTheDocument()
    expect(screen.getByText('85.0')).toBeInTheDocument()
  })

  it('switches to another microcycle on tab click', async () => {
    const user = userEvent.setup()
    render(<WorkoutPlan plan={mockPlan} />)

    await user.click(screen.getByRole('tab', { name: /week 2/i }))

    expect(screen.getByText('Squat')).toBeInTheDocument()
    expect(screen.getByText('70.0')).toBeInTheDocument()
  })
})
