/* @flow */

import 'react-native'
import React from 'react'
import CourseList from '../CourseList.js'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseList width={320} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with wide device', () => {
  let tree = renderer.create(
    <CourseList width={768} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
