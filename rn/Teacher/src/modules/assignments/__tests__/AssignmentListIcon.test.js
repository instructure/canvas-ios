/* @flow */

import 'react-native'
import React from 'react'
import AssignmentListRowIcon from '../components/AssignmentListRowIcon'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders published correctly', () => {
  let tree = renderer.create(
    <AssignmentListRowIcon published={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders unpublished correctly', () => {
  let tree = renderer.create(
    <AssignmentListRowIcon published={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
