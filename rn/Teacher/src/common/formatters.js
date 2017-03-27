// @flow

import i18n from 'format-message'
import moment from 'moment'

export function formattedDueDate (assignment: Assignment): string {
  let invalidDate = i18n('No due date')

  if (!assignment.due_at) {
    return invalidDate
  }

  let date
  let dateString
  let timeString

  try {
    date = new Date(assignment.due_at)

    if (!moment(date).isValid()) {
      return invalidDate
    }

    dateString = moment(date).format('ll')
    timeString = moment(date).format('LT')
  } catch (e) {
    return invalidDate
  }

  const now = Date.now()
  if (moment(now).isAfter(date)) {
    return i18n('Closed • {dateString} at {timeString}', { dateString, timeString })
  }

  return i18n('Due {dateString} at {timeString}', { dateString, timeString })
}
