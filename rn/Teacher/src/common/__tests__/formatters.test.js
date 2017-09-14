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
  it('works for pass', () => {
    expect(formatGradeText('pass')).toEqual('Pass')
  })
  it('works for complete', () => {
    expect(formatGradeText('complete')).toEqual('Complete')
  })
  it('works for fail', () => {
    expect(formatGradeText('fail')).toEqual('Fail')
  })
  it('works for incomplete', () => {
    expect(formatGradeText('incomplete')).toEqual('Incomplete')
  })
  it('passes through non number grades', () => {
    expect(formatGradeText('yo')).toEqual('yo')
  })
  it('gives back a percentage', () => {
    expect(formatGradeText('75%', 'percent')).toEqual('75%')
  })
  it('rounds percents to 2 decimals', () => {
    expect(formatGradeText('75.985%', 'percent')).toEqual('75.99%')
  })
  it('gives back points', () => {
    expect(formatGradeText('1000', 'points')).toEqual('1,000')
  })
  it('rounds points to 2 decimals', () => {
    expect(formatGradeText('1000.985', 'points')).toEqual('1,000.99')
  })
})

describe('edge cases', () => {
  it('should handle bad data', () => {
    let result = formattedDueDate(null)
    expect(result).toEqual('No Due Date')
  })
})
