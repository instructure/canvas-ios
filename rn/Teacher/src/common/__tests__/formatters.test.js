// @flow

import {
  formattedDueDateWithStatus,
  formattedDueDate,
  extractTimeString,
  extractDateString,
} from '../formatters'

import { extractDateFromString } from '../../utils/dateUtils'

import i18n from 'format-message'
import moment from 'moment'

describe('assignment due date with status', () => {
  test('due date in future', () => {
    const dueAt = '2117-03-28T15:07:56.312Z'
    const date = extractDateFromString(dueAt)
    const dueDate = formattedDueDateWithStatus(date)
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(`Due ${dateString} at ${timeString}`)
  })

  test('due date in past', () => {
    const dueAt = '1986-03-28T15:07:56.312Z'
    const lockAt = '1986-03-28T15:07:56.312Z'
    const dueDate = formattedDueDateWithStatus(extractDateFromString(dueAt), extractDateFromString(lockAt))
    const dateString = i18n.date(new Date(dueAt), 'medium')
    const timeString = i18n.time(new Date(dueAt), 'short')
    expect(dueDate).toEqual(`Closed • ${dateString} at ${timeString}`)
  })

  test('due date that is missing', () => {
    const garbage = formattedDueDateWithStatus(null)
    expect(garbage).toEqual('No due date')
  })

  test('due date that is garbage', () => {
    const garbage = formattedDueDateWithStatus(new Date('lkjaklsjdfljaslkdfjads'))
    expect(garbage).toEqual('No due date')
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
    expect(garbage).toEqual('No due date')
  })
})

describe('util functions', () => {
  test('extractTimeString', () => {
    const date = new Date('2117-03-28T15:07:56.312Z')
    const formattedTime = extractTimeString(date)
    const timeString = moment(date).format('LT')
    expect(formattedTime).toEqual(timeString)
  })

  test('extractTimeString with garbage', () => {
    const date = new Date('jlakjsdflkjasldkfkjalsd')
    const formattedTime = extractTimeString(date)
    expect(formattedTime).toEqual(null)
  })

  test('extractDateString', () => {
    const date = new Date('2117-03-28T15:07:56.312Z')
    const formattedDate = extractDateString(date)
    const dateString = moment(date).format('ll')
    expect(formattedDate).toEqual(dateString)
  })

  test('extractDateString with garbage', () => {
    const date = new Date('jlakjsdflkjasldkfkjalsd')
    const formattedTime = extractTimeString(date)
    expect(formattedTime).toEqual(null)
  })
})

describe('edge cases', () => {
  it('should handle bad data', () => {
    let result = formattedDueDate(null)
    expect(result).toEqual('No due date')
  })
})
