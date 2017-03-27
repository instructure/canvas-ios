// @flow

import i18n from 'format-message'
import moment from 'moment'

export function formattedDueDate (assignment: Assignment): string {
  if (!assignment.due_at) {
    return i18n('No due date')
  }

  let date
  let dateString
  let timeString

  try {
    date = new Date(assignment.due_at)
    dateString = i18n.date(date, 'medium')
    timeString = i18n.time(date, 'short')
  } catch (e) {
    return i18n('No due date')
  }

  const now = Date.now()
  if (moment(now).isAfter(date)) {
    return i18n('Closed • {dateString} at {timeString}', { dateString, timeString })
  }

  return i18n('Due {dateString} at {timeString}', { dateString, timeString })
}
