/* @flow */

import 'react-native'
import React from 'react'
import { CourseDetails } from '../CourseDetails.js'
import explore from '../../../../../test/helpers/explore'
import { route } from '../../../../routing'

const template = {
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/tab'),
  ...require('../../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../routing')

let course = template.course()

let defaultProps = {
  navigator: template.navigator(),
  course,
  tabs: [template.tab()],
  courseColors: template.customColors(),
  courseID: course.id,
}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly without tabs', () => {
  let tree = renderer.create(
    <CourseDetails {...defaultProps} tabs={[]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('go back to course list', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      pop: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <CourseDetails {...props} />
  ).toJSON()

  const allButton = explore(tree).selectByID('course-details.navigation-back-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.pop).toHaveBeenCalled()
})

test('select tab', () => {
  const tab = template.tab({
    id: 'assignments',
    html_url: '/courses/12/assignments',
  })
  const props = {
    ...defaultProps,
    course: template.course({ id: 12 }),
    tabs: [tab],
    navigator: template.navigator({
      push: jest.fn(),
    }),
  }

  let tree = renderer.create(
    <CourseDetails {...props} />
  ).toJSON()

  const tabRow: any = explore(tree).selectByID('courses-details.tab-touchable-row-assignments')
  tabRow.props.onPress()

  expect(props.navigator.push).toHaveBeenCalledWith(route('/courses/12/assignments'))
})
