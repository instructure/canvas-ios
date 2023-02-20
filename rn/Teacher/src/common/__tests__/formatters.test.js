//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import {
  formattedDueDateWithStatus,
  formattedDueDate,
  formatGradeText,
  formatGrade,
  formatStudentGrade,
  personDisplayName,
} from '../formatters'
import { extractDateFromString } from '../../utils/dateUtils'
import i18n from 'format-message'
import * as template from '../../__templates__/'

describe('formattedDueDateWithStatus', () => {
  it('formats due date in future', () => {
    const dueAt = '2117-03-28T15:07:56.312Z'
    const date = extractDateFromString(dueAt)
    const dueDate = String(formattedDueDateWithStatus(date))
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    const expectedString = String(`Due ${dateString} at ${timeString}`).replace(/\s/g, ' ')
    expect(dueDate).toEqual(expectedString)
  })

  it('formats due date in past', () => {
    const dueAt = '1986-03-28T15:07:56.312Z'
    const lockAt = '1986-03-28T15:07:56.312Z'
    const dueDate = formattedDueDateWithStatus(extractDateFromString(dueAt), extractDateFromString(lockAt))
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(['Closed', `${dateString} at ${timeString}`])
  })

  it('formats due date that is missing', () => {
    const garbage = formattedDueDateWithStatus(null)
    expect(garbage).toEqual(['No Due Date'])
  })

  it('formats due date that is garbage', () => {
    const garbage = formattedDueDateWithStatus(new Date('lkjaklsjdfljaslkdfjads'))
    expect(garbage).toEqual(['No Due Date'])
  })
})

describe('formattedDueDate', () => {
  test('it formats correctly', () => {
    const dueAt = '2117-03-28T15:07:56.312Z'
    const date = extractDateFromString(dueAt)
    const dueDate = formattedDueDate(date)
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(`${dateString} at ${timeString}`)
  })

  it('formats garbage', () => {
    const garbage = formattedDueDate(new Date('klaljsdflkjs'))
    expect(garbage).toEqual('No Due Date')
  })

  it('should handle bad data', () => {
    let result = formattedDueDate(null)
    expect(result).toEqual('No Due Date')
  })
})

describe('formatGrade', () => {
  it('rounds decimals', () => {
    expect(formatGrade(1.1234)).toEqual('1.12')
    expect(formatGrade(1.789)).toEqual('1.79')
    expect(formatGrade(2.1189)).toEqual('2.12') // MBL-11426
  })

  it('does not round up to next integer', () => {
    expect(formatGrade(9.999)).toEqual('9.99')
  })
})

describe('formatGradeText', () => {
  it('works for pass', () => {
    expect(formatGradeText({ grade: 'pass' })).toEqual('Pass')
  })
  it('works for complete', () => {
    expect(formatGradeText({ grade: 'complete' })).toEqual('Complete')
  })
  it('works for fail', () => {
    expect(formatGradeText({ grade: 'fail' })).toEqual('Fail')
  })
  it('works for incomplete', () => {
    expect(formatGradeText({ grade: 'incomplete' })).toEqual('Incomplete')
  })
  it('passes through non number grades', () => {
    expect(formatGradeText({ grade: 'yo' })).toEqual('yo')
  })
  it('gives back a percentage', () => {
    expect(formatGradeText({ grade: '75%', gradingType: 'percent' })).toEqual('75%')
  })
  it('rounds percents to 2 decimals', () => {
    expect(formatGradeText({ grade: '75.985%', gradingType: 'percent' })).toEqual('75.99%')
  })
  it('gives back points', () => {
    expect(formatGradeText({ grade: '1000', gradingType: 'points' })).toEqual('1,000')
  })
  it('rounds points to 2 decimals', () => {
    expect(formatGradeText({ grade: '1000.985', gradingType: 'points' })).toEqual('1,000.99')
  })
  it('prefers score over grade', () => {
    expect(formatGradeText({ grade: '2.99', score: 3, gradingType: 'points', pointsPossible: 5 })).toEqual('3/5')
  })
})

describe('formatStudentGrade', () => {
  it('formats no submission', () => {
    const assignment = template.assignment({
      submission: null,
      points_possible: 10,
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('- / 10')
  })

  it('formats excused', () => {
    const assignment = template.assignment({
      points_possible: 10,
      submission: {
        excused: true,
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('Excused / 10')
  })

  it('formats no score', () => {
    const assignment = template.assignment({
      points_possible: 10,
      submission: {
        score: null,
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('- / 10')
  })

  it('formats pass_fail with complete', () => {
    const assignment = template.assignment({
      grading_type: 'pass_fail',
      points_possible: 10,
      submission: {
        score: 1,
        grade: 'complete',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('Complete / 10')
  })

  it('formats pass_fail with incomplete', () => {
    const assignment = template.assignment({
      grading_type: 'pass_fail',
      points_possible: 10,
      submission: {
        score: 0,
        grade: 'incomplete',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('Incomplete / 10')
  })

  it('formats points', () => {
    const assignment = template.assignment({
      grading_type: 'points',
      points_possible: 10,
      submission: {
        score: 10,
        grade: '10',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('10 / 10')
  })

  it('formats points with decimals', () => {
    const assignment = template.assignment({
      grading_type: 'points',
      points_possible: 10,
      submission: {
        score: 8.14,
        grade: '8.1422349823049823',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('8.14 / 10')
  })

  it('formats percent', () => {
    const assignment = template.assignment({
      grading_type: 'percent',
      points_possible: 10,
      submission: {
        score: 10,
        grade: '100%',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('10 / 10 (100%)')
  })

  it('formats letter_grade', () => {
    const assignment = template.assignment({
      grading_type: 'letter_grade',
      points_possible: 10,
      submission: {
        score: 10,
        grade: 'A',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('10 / 10 (A)')
  })

  it('formats gpa_scale', () => {
    const assignment = template.assignment({
      grading_type: 'gpa_scale',
      points_possible: 10,
      submission: {
        score: 9.999,
        grade: 'A-',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('9.99 / 10 (A-)')
  })

  it('formats not_graded', () => {
    const assignment = template.assignment({
      grading_type: 'not_graded',
      submission: {
        score: 1,
        grade: '1',
      },
    })
    const result = formatStudentGrade(assignment)
    expect(result).toEqual('')
  })
})

describe('personDisplayName', () => {
  it('formats without pronouns', () => {
    expect(personDisplayName('John Doe')).toEqual('John Doe')
  })

  it('formats with pronouns', () => {
    expect(personDisplayName('John Doe', 'He/Him')).toEqual('John Doe (He/Him)')
  })
})
