// @flow

import { formattedDueDate } from '../formatters'
import i18n from 'format-message'

const template = {
  ...require('../../api/canvas-api/__templates__/assignments'),
}

test('test assignment due date in future', () => {
  const dueAt = '2117-03-28T15:07:56.312Z'
  const assignment = template.assignment({
    due_at: dueAt,
  })
  const dueDate = formattedDueDate(assignment)
  const date = i18n.date(new Date(dueAt), 'medium')
  const time = i18n.time(new Date(dueAt), 'short')
  expect(dueDate).toEqual(`Due ${date} at ${time}`)
})

test('test assignment due date in past', () => {
  const dueAt = '1986-03-28T15:07:56.312Z'
  const assignment = template.assignment({
    due_at: dueAt,
  })
  const dueDate = formattedDueDate(assignment)
  const date = i18n.date(new Date(dueAt), 'medium')
  const time = i18n.time(new Date(dueAt), 'short')
  expect(dueDate).toEqual(`Closed • ${date} at ${time}`)
})

test('test assignment due date that is missing', () => {
  const assignment = template.assignment({
    due_at: null,
  })
  const garbage = formattedDueDate(assignment)
  expect(garbage).toEqual('No due date')
})

test('test assignment due date that is garbage', () => {
  const assignment = template.assignment({
    due_at: 'kljalsjdkfljalsdjfald',
  })
  const garbage = formattedDueDate(assignment)
  expect(garbage).toEqual('No due date')
})
