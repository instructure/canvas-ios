//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import {
  formattedDueDateWithStatus,
  formattedDueDate,
  formatGradeText,
} from '../formatters'

import { extractDateFromString } from '../../utils/dateUtils'

import i18n from 'format-message'

describe('assignment due date with status', () => {
  test('due date in future', () => {
    const dueAt = '2117-03-28T15:07:56.312Z'
    const date = extractDateFromString(dueAt)
    const dueDate = formattedDueDateWithStatus(date)
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual([`Due ${dateString} at ${timeString}`])
  })

  test('due date in past', () => {
    const dueAt = '1986-03-28T15:07:56.312Z'
    const lockAt = '1986-03-28T15:07:56.312Z'
    const dueDate = formattedDueDateWithStatus(extractDateFromString(dueAt), extractDateFromString(lockAt))
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(['Closed', `${dateString} at ${timeString}`])
  })

  test('due date that is missing', () => {
    const garbage = formattedDueDateWithStatus(null)
    expect(garbage).toEqual(['No Due Date'])
  })

  test('due date that is garbage', () => {
    const garbage = formattedDueDateWithStatus(new Date('lkjaklsjdfljaslkdfjads'))
    expect(garbage).toEqual(['No Due Date'])
  })
})

describe('due date with status', () => {
  test('due date', () => {
    const dueAt = '2117-03-28T15:07:56.312Z'
    const date = extractDateFromString(dueAt)
    const dueDate = formattedDueDate(date)
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(`${dateString} at ${timeString}`)
  })

  test('test assignment due date that is garbage', () => {
    const garbage = formattedDueDate(new Date('klaljsdflkjs'))
    expect(garbage).toEqual('No Due Date')
  })
})

describe('formatGradeText', () => {
  test('formatGradeText with whole number', () => {
    const grade = '75'
    const formattedGrade = formatGradeText(grade, 0)
    expect(formattedGrade).toEqual('75')
  })

  test('formatGradeText removes unnecesary decimals', () => {
    const grade = '75'
    const formattedGrade = formatGradeText(grade, 2)
    expect(formattedGrade).toEqual('75')

    const grade1 = '75.000000000'
    const formattedGrade1 = formatGradeText(grade1, 5)
    expect(formattedGrade1).toEqual('75')
  })

  test('formatGradeText with decimal places', () => {
    const grade1 = '75.1234567'
    const formattedGrade1 = formatGradeText(grade1, 0)
    expect(formattedGrade1).toEqual('75')

    const grade2 = '75.1234567'
    const formattedGrade2 = formatGradeText(grade2, 1)
    expect(formattedGrade2).toEqual('75.1')

    const grade3 = '75.129'
    const formattedGrade3 = formatGradeText(grade3, 2)
    expect(formattedGrade3).toEqual('75.13')

    const grade4 = '75.1234567'
    const formattedGrade4 = formatGradeText(grade4, 6)
    expect(formattedGrade4).toEqual('75.123457')
  })

  test('formatGradeText with not a number', () => {
    const grade = 'excused'
    const formattedGrade = formatGradeText(grade, 2)
    expect(formattedGrade).toEqual('excused')
  })
})

describe('edge cases', () => {
  it('should handle bad data', () => {
    let result = formattedDueDate(null)
    expect(result).toEqual('No Due Date')
  })
})
