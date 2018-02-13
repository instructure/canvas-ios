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

/* eslint-disable flowtype/require-valid-file-annotation */

import 'react-native'
import React from 'react'
import * as courseTemplate from '../../../../__templates__/course'
import explore from '../../../../../test/helpers/explore'
import CourseCard from '../CourseCard'
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  onPress: () => {},
  course: courseTemplate.course(),
  color: '#333',
  style: {},
  initialHeight: 100,
  onCoursePreferencesPressed: () => {},
}

it('renders', () => {
  let tree = renderer.create(
    <CourseCard
      {...defaultProps}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

it('it calls props.onPress when it is selected', () => {
  let onPress = jest.fn()
  let tree = renderer.create(
    <CourseCard {...defaultProps} onPress={onPress} />
  ).toJSON()

  let button: any = explore(tree).selectByID('course-' + defaultProps.course.id)
  button.props.onPress()

  expect(onPress).toHaveBeenCalledWith(defaultProps.course)
})

it('calls props.onCoursePreferencesPressed when the kabob is selected', () => {
  let onCoursePreferencesPressed = jest.fn()
  let tree = renderer.create(
    <CourseCard {...defaultProps} onCoursePreferencesPressed={onCoursePreferencesPressed} />
  ).toJSON()

  let button = explore(tree).selectByID(`course-card.kabob-${defaultProps.course.id}`) || {}
  button.props.onPress()

  expect(onCoursePreferencesPressed).toHaveBeenCalledWith(defaultProps.course.id)
})

it('renders with image url', () => {
  let course = courseTemplate.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
  expect(
    renderer.create(
      <CourseCard {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders without image url', () => {
  let course = courseTemplate.course({ image_download_url: null })
  expect(
    renderer.create(
      <CourseCard {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders with empty image url', () => {
  let course = courseTemplate.course({ image_download_url: '' })
  expect(
    renderer.create(
      <CourseCard {...defaultProps} course={course} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders with a grade', () => {
  let course = courseTemplate.course()
  let grade = { currentDisplay: 'A-' }
  expect(
    renderer.create(
      <CourseCard {...defaultProps} course={course} grade={grade} showGrade={true} />
    ).toJSON()
  ).toMatchSnapshot()
})

it('renders with a grade even if the grade does not exist', () => {
  let course = courseTemplate.course()
  expect(
    renderer.create(
      <CourseCard {...defaultProps} course={course} showGrade={true} />
    ).toJSON()
  ).toMatchSnapshot()
})
