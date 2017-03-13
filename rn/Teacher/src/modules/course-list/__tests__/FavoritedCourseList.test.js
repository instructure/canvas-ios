/* @flow */

import 'react-native'
import React from 'react'
import { FavoritedCourseList } from '../FavoritedCourseList.js'
import explore from '../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('TouchableHighlight', () => 'TouchableHighlight')

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
  refreshCourses: () => {},
  pending: 0,
}

test('render', () => {
  let tree = renderer.create(
    <FavoritedCourseList {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render without courses', () => {
  let tree = renderer.create(
    <FavoritedCourseList {...defaultProps} courses={[]} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refresh courses', () => {
  const refresh = jest.fn()
  renderer.create(
    <FavoritedCourseList {...defaultProps} refreshCourses={refresh} />
  )
  expect(refresh).toHaveBeenCalled()
})

test('select course', () => {
  const course = template.course({ is_favorite: true })
  const props = {
    ...defaultProps,
    courses: [course],
    navigator: {
      push: jest.fn(),
    },
  }
  let tree = renderer.create(
    <FavoritedCourseList {...props} />
  ).toJSON()

  const courseCard = explore(tree).selectByID(course.course_code) || {}
  courseCard.props.onPress()
  expect(props.navigator.push).toHaveBeenCalled()
  const pushed = props.navigator.push.mock.calls.slice(-1).pop()[0]
  expect(pushed.screen).toEqual('teacher.CourseDetails')
})

test('go to all courses', () => {
  const props = {
    ...defaultProps,
    navigator: {
      push: jest.fn(),
    },
  }
  let tree = renderer.create(
    <FavoritedCourseList {...props} />
  ).toJSON()

  const allButton = explore(tree).selectByID('course-list.see-all-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.push).toHaveBeenCalledWith({
    screen: 'teacher.AllCourseList',
    title: 'All Courses',
    backButtonTitle: 'Courses',
  })
})
