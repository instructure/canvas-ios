// @flow

import i18n from 'format-message'
import moment from 'moment'
import { isDateValid } from '../utils/dateUtils'

const noDueDateString = i18n('No due date')

export function formattedDueDate (date: ?Date): string {
  if (!date) return noDueDateString

  const dateString = extractDateString(date)
  const timeString = extractTimeString(date)

  if (!dateString || !timeString) return noDueDateString

  return i18n('{dateString} at {timeString}', { dateString, timeString })
}

export function formattedDueDateWithStatus (dueAt: ?Date, lockAt: ?Date): string {
  if (!dueAt) return noDueDateString

  const dateString = extractDateString(dueAt)
  const timeString = extractTimeString(dueAt)

  if (!dateString || !timeString) return noDueDateString

  const now = Date.now()
  if (lockAt && moment(now).isAfter(lockAt)) {
    return i18n('Closed • {dateString} at {timeString}', { dateString, timeString })
  }

  return i18n('Due {dateString} at {timeString}', { dateString, timeString })
}

export function extractDateString (date: Date): ?string {
  if (!isDateValid(date)) return null
  return moment(date).format('ll')
}

export function extractTimeString (date: Date): ?string {
  if (!isDateValid(date)) return null
  return moment(date).format('LT')
}
