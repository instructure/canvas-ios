/* @flow */

import 'react-native'
import React from 'react'
import CourseDetailsTab from '../CourseDetailsTab.js'

const template = {
  ...require('../../../../../api/canvas-api/__templates__/tab'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const defaultProps = {
  tab: template.tab(),
  courseColor: 'white',
  onPress: () => {},
}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetailsTab {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('default icon', () => {
  const props = {
    ...defaultProps,
    tab: template.tab({ id: 'test default icon' }),
  }

  let tree = renderer.create(
    <CourseDetailsTab {...props} />
  )

  expect(tree).toMatchSnapshot()
})
