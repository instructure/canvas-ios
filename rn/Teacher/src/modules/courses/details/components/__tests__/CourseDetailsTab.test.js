/* @flow */

import 'react-native'
import React from 'react'
import CourseDetailsTab from '../CourseDetailsTab.js'

const template = {
  ...require('../../../../../api/canvas-api/__templates__/tab'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders correctly', () => {
  const tab = template.tab()
  const courseColor = 'white'
  const onPress = jest.fn()
  let tree = renderer.create(
    <CourseDetailsTab tab={tab} courseColor={courseColor} onPress={onPress} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
