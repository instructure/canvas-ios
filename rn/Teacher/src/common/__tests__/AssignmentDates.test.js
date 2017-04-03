/**
 * @flow
 */

import AssignmentDates from '../AssignmentDates'
import moment from 'moment'

const template = {
  ...require('../../api/canvas-api/__templates__/assignments'),
}

test('assignment dates should have a single due date', () => {
  const assignment = template.assignment()
  const dates = new AssignmentDates(assignment)

  expect(dates.hasMultipleDueDates()).toEqual(false)
  expect(dates.bestDueAt()).toBeDefined()
  expect(dates.firstDate()).toBeUndefined()

  expect(dates.bestAvailableFrom()).toBeDefined()
  expect(dates.bestAvailableTo()).toBeDefined()
})

test('assignment dates should have a multiple due date', () => {
  const assignment = template.assignment({
    all_dates: [template.assignmentDueDate(), template.assignmentDueDate()],
  })
  const dates = new AssignmentDates(assignment)

  expect(dates.hasMultipleDueDates()).toEqual(true)
  expect(dates.bestDueAt()).toBeDefined()
  expect(dates.bestAvailableFrom()).toBeDefined()
  expect(dates.bestAvailableTo()).toBeDefined()
})

describe('assignment date titles', () => {
  test('base title with no due dates', () => {
    const assignment = template.assignment()
    const dates = new AssignmentDates(assignment)

    expect(dates.bestDueDateTitle()).toEqual('-')
  })

  it('base due date has a title of everybody', () => {
    const assignment = template.assignment({
      due_at: undefined,
      all_dates: [template.assignmentDueDate({ base: true })],
    })
    const dates = new AssignmentDates(assignment)
    expect(dates.bestDueDateTitle()).toEqual('Everyone')
  })

  it('due date for only one student should have the correct title', () => {
    const assignment = template.assignment({
      due_at: undefined,
      all_dates: [template.assignmentDueDate({ base: false, title: '1 student' })],
    })
    const dates = new AssignmentDates(assignment)
    expect(dates.bestDueDateTitle()).toEqual('1 student')
  })
})

it('availabilityClosed should return false if the lock_at date is in the future on the outer assignment object', () => {
  const lockAt = moment().add(1, 'day').format()
  const assignment = template.assignment({
    lock_at: lockAt,
    all_dates: [template.assignmentDueDate({ lock_at: lockAt })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(false)
})

it('availabilityClosed should return false if the lock_at date is in the future in all_dates', () => {
  const lockAt = moment().add(1, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: lockAt })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(false)
})

it('availabilityClosed should return true if the lock_at date is in the past in the outer assignment object', () => {
  const lockAt = moment().subtract(1, 'day').format()
  const assignment = template.assignment({
    lock_at: lockAt,
    all_dates: [template.assignmentDueDate({ lock_at: lockAt })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(true)
})

it('availabilityClosed should return true if the lock_at date is in the past in all_dates', () => {
  const lockAt = moment().subtract(1, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: lockAt })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(true)
})

it('availabilityClosed should return true all dates are passed', () => {
  const one = moment().subtract(1, 'day').format()
  const two = moment().subtract(2, 'day').format()
  const three = moment().subtract(3, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: one }), template.assignmentDueDate({ lock_at: two }), template.assignmentDueDate({ lock_at: three })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(true)
})

it('availabilityClosed should return false if not all dates have passed', () => {
  const one = moment().subtract(1, 'day').format()
  const two = moment().subtract(2, 'day').format()
  const three = moment().add(3, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: one }), template.assignmentDueDate({ lock_at: two }), template.assignmentDueDate({ lock_at: three })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(false)
})

describe('assignment extraction', () => {
  it('should extract the outer level due date', () => {
    const assignment = template.assignment()
    const dates = new AssignmentDates(assignment)
    const date = dates.extractDateWithKey('due_at')
    expect(date).toBeDefined()
  })

  it('should extract the a date from base date', () => {
    const assignment = template.assignment({
      due_at: undefined,
      all_dates: [template.assignmentDueDate({ base: true })],
    })
    const dates = new AssignmentDates(assignment)
    const date = dates.extractDateWithKey('due_at')
    expect(date).toBeDefined()
  })

  it('should extract the a date from first date', () => {
    const assignment = template.assignment({
      due_at: undefined,
      all_dates: [template.assignmentDueDate({ base: undefined })],
    })
    const dates = new AssignmentDates(assignment)
    const date = dates.extractDateWithKey('due_at')
    expect(date).toBeDefined()
  })

  it('should not blow up if there is literally nothing', () => {
    const assignment = template.assignment({
      due_at: undefined,
    })
    const dates = new AssignmentDates(assignment)
    const date = dates.extractDateWithKey('due_at')
    expect(date).toBeNull()
  })
})
