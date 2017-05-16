/* @flow */

import 'react-native'
import React from 'react'
import CourseDetailsSplitViewPlaceholder from '../CourseDetailsSplitViewPlaceholder'

const template = {
  ...require('../../../../../api/canvas-api/__templates__/course'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const defaultProps = {
  course: template.course(),
  courseColor: 'white',
}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetailsSplitViewPlaceholder {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
