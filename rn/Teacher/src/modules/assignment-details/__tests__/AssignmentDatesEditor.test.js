/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDatesEditor from '../components/AssignmentDatesEditor.js'
import renderer from 'react-test-renderer'

jest.mock('LayoutAnimation', () => ({
  easeInEaseOut: jest.fn(),
}))

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

test('render correctly', () => {
  let assignment = template.assignment({
    all_dates: [template.assignmentDueDate()],
  })
  let tree = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render correctly with overide', () => {
  let override = template.assignmentOverride({
    id: '12345',
  })
  let dueDate = template.assignmentDueDate({
    id: override.id,
  })
  let assignment = template.assignment({
    all_dates: [dueDate],
    overrides: [override],
  })
  let tree = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('adds a new due date correctly', () => {
  let assignment = template.assignment({
    all_dates: [template.assignmentDueDate()],
  })
  let component = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).getInstance()
  component.addAdditionalDueDate()
  expect(component.state.dates.length).toEqual(2)
})

test('validation should work correctly', () => {
  let assignment = template.assignment({
    all_dates: [template.assignmentDueDate()],
  })
  let component = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).getInstance()
  component.addAdditionalDueDate()
  expect(component.validate()).toBeTruthy
})

test('validation should be false when due date is after lock date', () => {
  let assignment = template.assignment({
    all_dates: [{
      base: false,
      due_at: '2017-06-01T07:59:00Z',
      lock_at: '2017-06-01T05:59:00Z',
    }],
  })

  let component = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).getInstance()
  component.addAdditionalDueDate()
  expect(component.validate()).toBeFalsy
})

test('validate correctly with overides', () => {
  let override = template.assignmentOverride({
    id: '12345',
    student_ids: ['12345'],
  })
  let dueDate = template.assignmentDueDate({
    id: override.id,
  })
  let everyoneDate = template.assignmentDueDate({ base: true })
  let assignment = template.assignment({
    all_dates: [dueDate, everyoneDate],
    overrides: [override],
  })
  let component = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).getInstance()
  expect(component.validate()).toBeTruthy()
})
