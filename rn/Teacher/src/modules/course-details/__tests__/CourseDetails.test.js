/* @flow */

import 'react-native'
import React from 'react'
import CourseDetails from '../CourseDetails.js'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetails course={courseTemplate.course()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
