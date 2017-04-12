/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDatesEditor from '../components/AssignmentDatesEditor.js'
import renderer from 'react-test-renderer'

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
  expect(component.validate()).toEqual(false)
})
