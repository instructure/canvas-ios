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

it('If "available to" date is there, and in the past, AND if "due" date is in the past, assignment should be marked closed.', () => {
  const one = moment().subtract(1, 'day').format()
  const two = moment().subtract(2, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    due_at: null,
    all_dates: [template.assignmentDueDate({ lock_at: one, due_at: one }), template.assignmentDueDate({ lock_at: two, due_at: one })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(true)
})

it('If "available to" date is not there, and if "due" date is in the past, assignment should be marked closed.', () => {
  const one = moment().subtract(1, 'day').format()
  const two = moment().subtract(2, 'day').format()
  const assignment = template.assignment({
    lock_at: null,
    due_at: null,
    all_dates: [template.assignmentDueDate({ due_at: one }), template.assignmentDueDate({ due_at: two })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(true)
})

// THE MOTHER OF ALL TESTS

/*
  As if today was April 4:

  If there are multiple due dates, all of the above must be true to be marked as closed. Ex:
  Due date 1
  Due: April 1
  Avail from: March 30
  Avail to: April 2
  Due date 2
  Due: –
  Avail from: Apr 5
  Avail to: April 8
  Due date 3
  Due: Apr 7
  Avail from: –
  Avail to: –
  In this scenario, we'd say "Multiple due dates" until April 8, when we would mark it "Availability: Closed"
*/
it('crazy due date and lock at stuff', () => {
  const dueDate1 = template.assignmentDueDate({
    due_at: moment().subtract(3, 'day').format(),
    lock_at: moment().subtract(2, 'day').format(),
    unlock_at: moment().subtract(4, 'day').format(),
  })

  const dueDate2 = template.assignmentDueDate({
    due_at: null,
    lock_at: moment().add(1, 'day').format(),
    unlock_at: moment().add(4, 'day').format(),
  })

  const dueDate3 = template.assignmentDueDate({
    due_at: moment().add(3, 'day').format(),
    lock_at: null,
    unlock_at: null,
  })

  const assignment = template.assignment({
    lock_at: null,
    due_at: null,
    all_dates: [dueDate1, dueDate2, dueDate3],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.availabilityClosed()).toEqual(false)
})

it('should extract override student ids if they are present', () => {
  const studentIDs = ['123', '1234']
  const assignment = template.assignment({
    overrides: [template.assignmentOverride({ student_ids: studentIDs })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.studentIDs()).toMatchObject(studentIDs)
})

it('should extract override student ids if they are present', () => {
  const one = ['123', '1234']
  const two = ['9876', '9876']
  const assignment = template.assignment({
    overrides: [template.assignmentOverride({ student_ids: one }), template.assignmentOverride({ student_ids: two })],
  })

  const dates = new AssignmentDates(assignment)
  expect(dates.studentIDs()).toMatchObject(one.concat(two))
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

describe('edge cases', () => {
  it('should handle when lock_at is missing', () => {
    const assignment = template.assignment({
      lock_at: null,
      all_dates: [template.assignmentDueDate({ lock_at: null })],
    })

    const dates = new AssignmentDates(assignment)
    expect(dates.availabilityClosed()).toEqual(false)
  })

  it('should handle when basically everything is missing', () => {
    const assignment = template.assignment({
      lock_at: null,
      all_dates: [
        template.assignmentDueDate({ lock_at: null, due_at: null }),
        template.assignmentDueDate({ lock_at: null, due_at: null })],
    })

    const dates = new AssignmentDates(assignment)
    expect(dates.availabilityClosed()).toEqual(false)
  })

  it('should not explode if there are zero overrides', () => {
    const dates = new AssignmentDates(template.assignment({ overrides: null }))
    expect(dates.overrides()).toHaveLength(0)
  })
})
