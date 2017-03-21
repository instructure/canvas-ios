/* @flow */

import 'react-native'
import React from 'react'
import CourseList from '../CourseList.js'
import groupCustomColors from '../../../../api/utils/group-custom-colors'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../api/canvas-api/__templates__/course'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const defaultProps = {
  width: 400,
  selectCourse: jest.fn(),
  customColors: groupCustomColors(template.customColors()).custom_colors.course,
  courses: [{ ...template.course(), color: '#112233' }],
  pending: 0,
  color: '#07f',
}

test('render courses', () => {
  const tree = renderer.create(
    <CourseList {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render courses pending', () => {
  const props = { ...defaultProps, pending: 1 }
  const tree = renderer.create(
    <CourseList {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render wide width', () => {
  const props = { ...defaultProps, width: 768 }
  const tree = renderer.create(
    <CourseList {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render narrow width', () => {
  const props = { ...defaultProps, width: 320 }
  const tree = renderer.create(
    <CourseList {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('select course', () => {
  const course = defaultProps.courses[0]
  const selectCourse = jest.fn()
  const props = { ...defaultProps, selectCourse: selectCourse }
  let tree = renderer.create(
    <CourseList {...props} />
  ).toJSON()

  const courseCard = explore(tree).selectByID(course.course_code) || {}
  courseCard.props.onPress()
  expect(selectCourse).toHaveBeenCalledWith(course)
})
