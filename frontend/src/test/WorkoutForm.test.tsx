import { render, screen, fireEvent } from '@testing-library/react'
import { WorkoutForm } from '../components/WorkoutForm'
import type { WorkoutPlanRequest } from '../types'
import { describe, it, expect, vi } from 'vitest'

describe('WorkoutForm', () => {
  it('shows validation errors when submitted empty', () => {
    const onSubmit = vi.fn()
    render(<WorkoutForm onSubmit={onSubmit} loading={false} />)

    fireEvent.click(screen.getByRole('button', { name: /generate plan/i }))

    expect(screen.getByText(/bench press 1rm must be at least 1 kg/i)).toBeInTheDocument()
    expect(screen.getByText(/squat 1rm must be at least 1 kg/i)).toBeInTheDocument()
    expect(screen.getByText(/deadlift 1rm must be at least 1 kg/i)).toBeInTheDocument()
    expect(onSubmit).not.toHaveBeenCalled()
  })

  it('calls onSubmit with correct data when form is valid', () => {
    const onSubmit = vi.fn()
    render(<WorkoutForm onSubmit={onSubmit} loading={false} />)

    fireEvent.change(screen.getByLabelText(/bench press 1rm/i), { target: { value: '115' } })
    fireEvent.change(screen.getByLabelText(/squat 1rm/i), { target: { value: '80' } })
    fireEvent.change(screen.getByLabelText(/deadlift 1rm/i), { target: { value: '140' } })

    fireEvent.click(screen.getByRole('button', { name: /generate plan/i }))

    expect(onSubmit).toHaveBeenCalledWith<[WorkoutPlanRequest]>({
      bench_press_1rm: 115,
      squat_1rm: 80,
      deadlift_1rm: 140,
    })
  })

  it('disables the button while loading', () => {
    render(<WorkoutForm onSubmit={vi.fn()} loading={true} />)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
