//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* @flow */

import 'react-native'
import React from 'react'
import CourseList from '../CourseList.js'
import groupCustomColors from '../../../../utils/group-custom-colors'
import explore from '../../../../../test/helpers/explore'

const template = {
  ...require('../../../../__templates__/course'),
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
  onCoursePreferencesPressed: jest.fn(),
  color: '#07f',
  onRefresh: jest.fn(),
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

test('calls props.onCoursePreferencesPressed when a kabob is pressed', () => {
  let onCoursePreferencesPressed = jest.fn()
  let tree = renderer.create(
    <CourseList {...defaultProps} onCoursePreferencesPressed={onCoursePreferencesPressed} />
  ).toJSON()

  let kabob = explore(tree).selectByID(`course-card.kabob-${defaultProps.courses[0].id}`) || {}
  kabob.props.onPress()
  expect(onCoursePreferencesPressed).toHaveBeenCalledWith(defaultProps.courses[0].id)
})
