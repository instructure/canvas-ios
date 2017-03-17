/* @flow */

import 'react-native'
import React from 'react'
import AssignmentListRow from '../components/AssignmentListRow'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  let assignment = template.assignment()
  let tree = renderer.create(
    <AssignmentListRow assignment={assignment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
