/* @flow */

import 'react-native'
import { formattedDate } from '../dateUtils'
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

