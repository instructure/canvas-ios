// @flow

import i18n from 'format-message'
import moment from 'moment'
import { isDateValid } from '../utils/dateUtils'

const noDueDateString = i18n('No Due Date')

export function formattedDueDate (date: ?Date): string {
  if (!date) return noDueDateString

  const dateString = extractDateString(date)
  const timeString = extractTimeString(date)

  if (!dateString || !timeString) return noDueDateString

  return i18n('{dateString} at {timeString}', { dateString, timeString })
}

export function formattedDueDateWithStatus (dueAt: ?Date, lockAt: ?Date): string[] {
  const dateString = formattedDueDate(dueAt)
  if (dateString === noDueDateString) return [noDueDateString]
  const now = Date.now()
  if (lockAt && moment(now).isAfter(lockAt)) {
    return [i18n('Closed'), dateString]
  }
  return [`Due ${dateString}`]
}

export function extractDateString (date: Date): ?string {
  if (!isDateValid(date)) return null
  return moment(date).format('ll')
}

export function extractTimeString (date: Date): ?string {
  if (!isDateValid(date)) return null
  return moment(date).format('LT')
}

export function formatGradeText (grade: string, decimals: number): string {
  if (isNaN(grade)) return grade
  let gradeText = grade
  gradeText = Math.round(Number(grade) * Math.pow(10, decimals)) / Math.pow(10, decimals)
  return String(gradeText)
}
