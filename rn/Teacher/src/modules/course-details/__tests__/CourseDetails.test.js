/* @flow */

import 'react-native'
import React from 'react'
import CourseDetails from '../CourseDetails.js'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  const course = {
    color: 'white',
    name: 'foo',
    course_code: 'bio 101',
  }
  let tree = renderer.create(
    <CourseDetails course={course} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
