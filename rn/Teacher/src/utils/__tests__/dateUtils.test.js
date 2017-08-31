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

/* @flow */

import 'react-native'
import { formattedDate, extractDateFromString } from '../dateUtils'
import timezoneMock from 'timezone-mock'

let utcDateString = '2017-06-01T05:59:00Z'

beforeEach(() => {
  timezoneMock.register('US/Pacific')
})

afterEach(() => {
  timezoneMock.unregister()
})

test('formats utc date string', () => {
  let expected = 'May 31, 2017 10:59 PM'
  let result = formattedDate(utcDateString, 'LLL')
  expect(result).toBe(expected)
})

test('handles undefined', () => {
  let expected = ''
  let result = formattedDate(undefined, 'LLL')
  expect(result).toBe(expected)
})

test('handles empty string', () => {
  let input = ''
  let expected = ''
  let result = formattedDate(input, 'll')
  expect(result).toBe(expected)
})

test('handles bad input', () => {
  timezoneMock.unregister()
  let input = 'foo'
  let expected = 'Invalid date'
  let result = formattedDate(input, 'LLL')
  expect(result).toBe(expected)
})

test('handles bad format string', () => {
  timezoneMock.unregister()
  let expected = 'foo'
  let result = formattedDate(utcDateString, 'foo')
  expect(result).toBe(expected)
})

test('handles default moment format', () => {
  let result = formattedDate(utcDateString)
  expect(result).toBe('May 31, 2017 10:59 PM')
})

test('handles bad data in extractDateFromString', () => {
  timezoneMock.unregister()
  expect(extractDateFromString(null)).toBe(null)
  expect(extractDateFromString('garbage')).toBe(null)
})
