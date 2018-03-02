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
import { isDateValid } from '../utils/dateUtils'

export function formattedDueDate (date: ?Date): string {
  if (!date || !isDateValid(date)) return i18n('No Due Date')
  return i18n('{date, date, medium} at {date, time, short}', { date })
}

export function formattedDueDateWithStatus (dueAt: ?Date, lockAt: ?Date): string[] {
  const dateString = formattedDueDate(dueAt)
  if (dateString === i18n('No Due Date')) return [dateString]
  const now = new Date()
  if (lockAt && now > lockAt) {
    return [i18n('Closed'), dateString]
  }
  return [i18n('Due {dateString}', { dateString })]
}

export function formatGradeText (grade: ?string, gradingType?: GradingType, pointsPossible?: number): ?string {
  if (!['points', 'percent'].includes(gradingType)) {
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

    if (isNaN(grade)) {
      return grade
    }

    return String(Math.round(Number(grade) * Math.pow(10, 2)) / Math.pow(10, 2))
  }

  if (gradingType === 'percent') {
    const percent = +(grade || '').split('%')[0]
    return i18n.number(percent / 100, 'percent')
  }
  const gradeNum = Math.round(Number(grade) * Math.pow(10, 2)) / Math.pow(10, 2)

  if (gradingType === 'points' && pointsPossible) {
    return `${i18n.number(gradeNum)}/${i18n.number(pointsPossible)}`
  }

  return i18n.number(gradeNum)
}
