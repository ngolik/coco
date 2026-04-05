import { render, screen, fireEvent } from '@testing-library/react'
import { WorkoutForm } from '../components/WorkoutForm'
import type { WorkoutPlanRequest } from '../types'
import { describe, it, expect, vi } from 'vitest'

describe('WorkoutForm', () => {
  it('shows validation errors when submitted empty', () => {
    const onSubmit = vi.fn()
    render(<WorkoutForm onSubmit={onSubmit} loading={false} />)

    fireEvent.click(screen.getByRole('button', { name: /generate plan/i }))

    expect(screen.getByText(/exercise name is required/i)).toBeInTheDocument()
    expect(screen.getByText(/1rm must be at least 1 kg/i)).toBeInTheDocument()
    expect(screen.getByText(/intensity must be between 30 and 100/i)).toBeInTheDocument()
    expect(screen.getByText(/number of sets must be between 3 and 5/i)).toBeInTheDocument()
    expect(onSubmit).not.toHaveBeenCalled()
  })

  it('calls onSubmit with correct data when form is valid', () => {
    const onSubmit = vi.fn()
    render(<WorkoutForm onSubmit={onSubmit} loading={false} />)

    fireEvent.change(screen.getByLabelText(/exercise name/i), {
      target: { value: 'Back Squat' },
    })
    fireEvent.change(screen.getByLabelText(/1rm/i), { target: { value: '100' } })
    fireEvent.change(screen.getByLabelText(/target intensity/i), { target: { value: '75' } })
    fireEvent.change(screen.getByLabelText(/number of sets/i), { target: { value: '4' } })
    fireEvent.change(screen.getByLabelText(/reps per set/i), { target: { value: '5' } })

    fireEvent.click(screen.getByRole('button', { name: /generate plan/i }))

    expect(onSubmit).toHaveBeenCalledWith<[WorkoutPlanRequest]>({
      exercise_name: 'Back Squat',
      one_rm_kg: 100,
      target_intensity_pct: 75,
      num_sets: 4,
      reps_per_set: 5,
      exercise_type: 'multi-joint',
    })
  })

  it('rejects intensity below 30', () => {
    const onSubmit = vi.fn()
    render(<WorkoutForm onSubmit={onSubmit} loading={false} />)

    fireEvent.change(screen.getByLabelText(/exercise name/i), {
      target: { value: 'Bench Press' },
    })
    fireEvent.change(screen.getByLabelText(/1rm/i), { target: { value: '80' } })
    fireEvent.change(screen.getByLabelText(/target intensity/i), { target: { value: '20' } })
    fireEvent.change(screen.getByLabelText(/number of sets/i), { target: { value: '3' } })
    fireEvent.change(screen.getByLabelText(/reps per set/i), { target: { value: '8' } })

    fireEvent.click(screen.getByRole('button', { name: /generate plan/i }))

    expect(screen.getByText(/intensity must be between 30 and 100/i)).toBeInTheDocument()
    expect(onSubmit).not.toHaveBeenCalled()
  })

  it('disables the button while loading', () => {
    render(<WorkoutForm onSubmit={vi.fn()} loading={true} />)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
