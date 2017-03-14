/* @flow */

import 'react-native'
import React from 'react'
import { AllCourseList } from '../AllCourseList.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const template = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

const courses = [
  template.course({
    name: 'Biology 101',
    course_code: 'BIO 101',
    short_name: 'BIO 101',
    id: 1,
    is_favorite: true,
  }),
  template.course({
    name: 'American Literature Psysicks foobar hello world 401',
    course_code: 'LIT 401',
    short_name: 'LIT 401',
    id: 2,
    is_favorite: false,
  }),
  template.course({
    name: 'Foobar 102',
    course_code: 'FOO 102',
    id: 3,
    short_name: 'FOO 102',
    is_favorite: true,
  }),
]

const colors = {
  '1': '#27B9CD',
  '2': '#8F3E97',
  '3': '#8F3E99',
}

let defaultProps = {
  navigator: template.navigator(),
  courses,
  customColors: colors,
  pending: 0,
}

test('render', () => {
  let tree = renderer.create(
    <AllCourseList {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('select course', () => {
  const course = template.course()
  const props = {
    ...defaultProps,
    courses: [course],
    navigator: template.navigator({
      push: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <AllCourseList {...props} />
  ).toJSON()

  const courseCard = explore(tree).selectByID(course.course_code) || {}
  courseCard.props.onPress()
  expect(props.navigator.push).toHaveBeenCalled()
  const pushed = props.navigator.push.mock.calls.slice(-1).pop()[0]
  expect(pushed.screen).toEqual('teacher.CourseDetails')
})
