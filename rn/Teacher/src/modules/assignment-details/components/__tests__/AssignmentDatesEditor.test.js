/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDatesEditor from '../AssignmentDatesEditor'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../../api/canvas-api/__templates__/assignments'),
}

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    all_dates: [template.assignmentDueDate({ base: true }), template.assignmentDueDate({ base: false })],
  })
  let tree = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render with single due date', () => {
  const assignment = template.assignment({
    all_dates: [template.assignmentDueDate({ base: true })],
  })
  let tree = renderer.create(
    <AssignmentDatesEditor assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
