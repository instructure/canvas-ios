// @flow

import moment from 'moment'

export function formattedDate (dateString?: ?string, momentFormat: string = 'LLL'): string {
  if (!dateString) return ''
  return moment(new Date(dateString)).format(momentFormat)
}

export function extractDateFromString (dateString: ?string): ?Date {
  if (!dateString) return null
  const date = new Date(dateString)
  if (!isDateValid(date)) return null
  return date
}

export function isDateValid (date: Date): boolean {
  if (isNaN(date.getTime())) {
    return false
  }

  return true
}
