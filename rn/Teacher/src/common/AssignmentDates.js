// @flow
//
// Assignment due dates are a little difficult to manage
// This object can be given an assignment, and it will manage all the weird little details about due dates for an assignment
// Due dates and availability are calculated from a combination of fields on the base assignment object, all_dates, and overrides
//
// Note! This object relies heavily on the all_dates parameter from the Assignment object. You must pass 'all_dates' to the API in order to get that

import { extractDateFromString } from '../utils/dateUtils'
import i18n from 'format-message'
import { flatten } from 'lodash'

export default class AssignmentDates {

  assignment: Assignment

  constructor (assignment: Assignment) {
    this.assignment = assignment
  }

  // Makes a best guess at a due date that will work in all circumstances
  // If there are multiple due dates, returns the first one that it can find
  // If there is truly no due date, returns null
  // Note: This returns a Date object, not a string!
  bestDueAt = (): ?Date => {
    return this.extractDateWithKey('due_at')
  }

  bestAvailableFrom = (): ?Date => {
    return this.extractDateWithKey('unlock_at')
  }

  bestAvailableTo = (): ?Date => {
    return this.extractDateWithKey('lock_at')
  }

  bestDueDateTitle = (): string => {
    const base = this.baseDate()
    if (base) {
      return i18n('Everyone')
    }

    const first = this.firstDate()
    if (first) {
      return first.title
    }

    return '-'
  }

  // all_dates from the api sometimes exists, sometimes it doesn't
  allDates = (): AssignmentDate[] => {
    return this.assignment.all_dates || []
  }

  overrides = (): AssignmentOverride[] => {
    return this.assignment.overrides || []
  }

  // Returns the base date, if one exists
  baseDate = (): ?AssignmentDate => {
    return this.allDates().filter((date) => date.base)[0]
  }

  firstDate = (): ?AssignmentDate => {
    return this.allDates()[0]
  }

  hasMultipleDueDates = (): boolean => {
    return this.allDates().length > 1
  }

  // ids for any students that specific due dates are assigned
  // This returns *all* studentIDs for all available dates
  studentIDs = (): string[] => {
    const ids = this.overrides().map((override) => {
      return override.student_ids || []
    })
    return flatten(ids)
  }

  overrideForID = (id: string): ?AssignmentOverride => {
    return this.overrides().find((override) => {
      return override.id === id
    })
  }

  // Private stuff, probably shouldn't use these....
  extractDateWithKey = (key: string): ?any => {
    if (this.assignment[key]) {
      return extractDateFromString(this.assignment[key])
    }

    const base = this.baseDate()
    if (base) {
      return extractDateFromString(base[key])
    }

    const first = this.firstDate()
    if (first) {
      return extractDateFromString(first[key])
    }

    return null
  }

  /*
  OMG, there are so many weird edge cases with this,
  I'm documenting them all in the tests so that all the cases can be understood

  // Returns true is *all* availability dates have passed, in correlation to their due dates
  // If there is no lock_at field, returns false
  */
  availabilityClosed = (): boolean => {
    // If there is one single lock_at, compare that against the current time.
    // If it's before the current time, the availability is closed
    if (this.allDates().length < 2) {
      let lockAt = this.assignment.lock_at

      // If the outer assignment document doesn't have a lock_at,
      // Check in the all_dates
      const firstDate = this.firstDate()
      if (!lockAt && firstDate) {
        lockAt = firstDate.lock_at
      }

      if (!lockAt) return false

      const date = new Date(lockAt)
      return Date.now() > date.getTime()
    }

    // If there are multiple due dates, ensure that they have *all* passed
    return this.allDates()
    .filter((date) => {
      const calculate = (date: Date): boolean => {
        return Date.now() < date.getTime()
      }

      // If there is only a due date, calculate based on that alone
      if (date.due_at && !date.lock_at) {
        return calculate(new Date(date.due_at))
      }

      // If there is a due_at and lock_at, both must have passed
      if (date.due_at && date.lock_at) {
        return calculate(new Date(date.due_at)) && calculate(new Date(date.lock_at))
      }

      // If only lock at, only it needs to be in the past
      if (!date.due_at && date.lock_at) {
        return calculate(new Date(date.lock_at))
      }

      // I doubt this case will ever be hit, but if it is, there are no dates, so let it through
      return true
    }).length === 0
  }
}
