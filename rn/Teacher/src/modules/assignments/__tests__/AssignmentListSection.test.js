/* @flow */

import 'react-native'
import React from 'react'
import AssignmentListSection from '../components/AssignmentListSection'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  let group = template.assignmentGroup()
  let tree = renderer.create(
    <AssignmentListSection assignmentGroup={group} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
