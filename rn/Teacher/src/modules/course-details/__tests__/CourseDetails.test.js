/* @flow */

import 'react-native'
import React from 'react'
import { CourseDetails } from '../CourseDetails.js'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/tab'),
  ...require('../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  navigator: template.navigator(),
  course: template.course(),
  tabs: [template.tab()],
  courseColors: template.customColors(),
}

let refresh: any
beforeEach(() => {
  refresh = jest.fn()
})

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} refreshTabs={refresh} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly without tabs', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} refreshTabs={refresh}/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refresh on mount', () => {
  renderer.create(
    <CourseDetails {...defaultProps} refreshTabs={refresh}/>
  )
  expect(refresh).toHaveBeenCalled()
})

test('go back to course list', () => {
  const props = {
    ...defaultProps,
    navigator: {
      pop: jest.fn(),
    },
  }
  let tree = renderer.create(
    <CourseDetails {...props} refreshTabs={refresh}/>
  ).toJSON()

  const allButton = explore(tree).selectByID('course-details.navigation-back-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.pop).toHaveBeenCalled()
})
