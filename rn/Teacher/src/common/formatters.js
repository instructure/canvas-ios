//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import i18n from 'format-message'
import moment from 'moment'
import { isDateValid } from '../utils/dateUtils'

export function formattedDueDate (date: ?Date): string {
  if (!date) return i18n('No Due Date')

  const dateString = extractDateString(date)
  const timeString = extractTimeString(date)

  if (!dateString || !timeString) return i18n('No Due Date')

  return i18n('{dateString} at {timeString}', { dateString, timeString })
}

export function formattedDueDateWithStatus (dueAt: ?Date, lockAt: ?Date): string[] {
  const dateString = formattedDueDate(dueAt)
  if (dateString === i18n('No Due Date')) return [i18n('No Due Date')]
  const now = Date.now()
  if (lockAt && moment(now).isAfter(lockAt)) {
    return [i18n('Closed'), dateString]
  }
  return [i18n('Due {dateString}', { dateString })]
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
  if (isNaN(grade)) {
    switch (grade) {
      case 'pass':
        return i18n('Pass')
      case 'complete':
        return i18n('Complete')
      case 'fail':
        return i18n('Fail')
      case 'incomplete':
        return i18n('Incomplete')
    }

    return grade
  }
  let gradeText = grade
  gradeText = Math.round(Number(grade) * Math.pow(10, decimals)) / Math.pow(10, decimals)
  return String(gradeText)
}
