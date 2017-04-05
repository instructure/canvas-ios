// @flow

import 'react-native'
import React from 'react'
import { AssignmentDueDates } from '../AssignmentDueDates'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../__templates__/react-native-navigation'),
}

test('renders', () => {
  const props = {
    assignment: template.assignment(),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with overrides', () => {
  const id = '123456'
  const date = template.assignmentDueDate({ id })
  const override = template.assignmentOverride({ id })
  const props = {
    assignment: template.assignment({
      all_dates: [date],
      overrides: [override],
    }),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with overrides and specific student ids', () => {
  const user = template.user()
  const id = '123456'
  const date = template.assignmentDueDate({ id })
  const override = template.assignmentOverride({ id, student_ids: [user.id] })
  const assignment = template.assignment({
    all_dates: [date],
    overrides: [override],
  })

  const refreshUsers = jest.fn()
  const props = {
    refreshUsers,
    assignment,
    assignmentID: assignment.id,
    users: {
      [user.id]: user,
    },
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
  expect(refreshUsers).toBeCalled()
})
