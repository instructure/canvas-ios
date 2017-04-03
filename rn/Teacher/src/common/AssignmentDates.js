// @flow
//
// Assignment due dates are a little difficult to manage
// This object can be given an assignment, and it will manage all the weird little details about due dates for an assignment
// Due dates and availability are calculated from a combination of fields on the base assignment object, all_dates, and overrides
//
// Note! This object relies heavily on the all_dates parameter from the Assignment object. You must pass 'all_dates' to the API in order to get that

import { extractDateFromString } from '../utils/dateUtils'
import i18n from 'format-message'

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

  // Returns true is *all* availability dates have passed
  // If there is no lock_at field, returns false
  availabilityClosed = (): boolean => {
    // If there is one single lock_at, compare that against
    // The current time. If it's before the current time, the availability is closed
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
    .filter((date) => date.lock_at)
    .filter((date) => {
      const lockAt = new Date(date.lock_at)
      return Date.now() < lockAt.getTime()
    }).length === 0
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
}
