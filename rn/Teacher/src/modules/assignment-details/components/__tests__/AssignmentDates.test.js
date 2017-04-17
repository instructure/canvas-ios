/**
 * @flow
 */

import 'react-native'
import React from 'react'
import AssignmentDates from '../AssignmentDates'
import renderer from 'react-test-renderer'
import moment from 'moment'

const template = {
  ...require('../../../../api/canvas-api/__templates__/assignments'),
}

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    due_at: undefined,
    all_dates: [template.assignmentDueDate({ base: true }), template.assignmentDueDate({ base: false })],
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render with multiple due dates', () => {
  const assignment = template.assignment({
    lock_at: moment().subtract('1', 'days'),
  })
  let tree = renderer.create(
    <AssignmentDates assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
