// @flow

import 'react-native'
import React from 'react'
import { AssignmentDueDates } from '../AssignmentDueDates'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest
  .mock('../../../routing')
  .mock('../../../routing/Screen')

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../__templates__/helm'),
}

test('renders', () => {
  const props = {
    assignment: template.assignment(),
    navigator: template.navigator(),
    onEditPressed: jest.fn(),
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
    navigator: template.navigator(),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders with overrides and specific student ids and sections', () => {
  const user = template.user()
  const studentId = '123456'
  const studentDate = template.assignmentDueDate({ id: studentId })
  const studentOverride = template.assignmentOverride({ id: studentId, student_ids: [user.id] })
  const sectionId = '9999999999'
  const sectionDate = template.assignmentDueDate({ id: sectionId, title: 'Section 1' })
  const sectionOverride = template.assignmentOverride({ id: sectionId })
  const messyDataOne = template.assignmentDueDate()
  const messyDataTwo = template.assignmentDueDate({ title: 'messy', id: 'invalid', unlock_at: null, lock_at: null, due_at: null })
  const assignment = template.assignment({
    all_dates: [studentDate, sectionDate, messyDataOne, messyDataTwo],
    overrides: [studentOverride, sectionOverride],
  })

  const refreshUsers = jest.fn()
  const props = {
    refreshUsers,
    assignment,
    assignmentID: assignment.id,
    users: {
      [user.id]: user,
    },
    navigator: template.navigator(),
    onEditPressed: jest.fn(),
  }

  let tree = renderer.create(
    <AssignmentDueDates {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
  expect(refreshUsers).toBeCalled()
})

test('calls onEditPressed when the edit button is pressed', () => {
  const onEditPressed = jest.fn()
  const assignment = template.assignment()
  let tree = renderer.create(
    <AssignmentDueDates onEditPressed={onEditPressed} assignmentID={assignment.id} courseID='1' assignment={assignment} />
  ).toJSON()
  const editButton: any = explore(tree).selectRightBarButton('assignment-due-dates.edit-btn')
  editButton.action()
  expect(onEditPressed).toHaveBeenCalled()
})
