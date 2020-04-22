//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import 'react-native'
import React from 'react'
import * as courseTemplate from '../../../../__templates__/course'
import explore from '../../../../../test/helpers/explore'
import CourseCard from '../CourseCard'
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  onPress: () => {},
  course: courseTemplate.course(),
  color: '#333',
  hideOverlay: false,
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

it('renders without the color overlay', () => {
  let tree = renderer.create(
    <CourseCard
      {...defaultProps}
      hideOverlay
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('it calls props.onPress when it is selected', () => {
  let onPress = jest.fn()
  let tree = renderer.create(
    <CourseCard {...defaultProps} onPress={onPress} />
  ).toJSON()

  let button: any = explore(tree).selectByID('CourseCardCell.' + defaultProps.course.id)
  button.props.onPress()

  expect(onPress).toHaveBeenCalledWith(defaultProps.course)
})

it('calls props.onCoursePreferencesPressed when the kabob is selected', () => {
  let onCoursePreferencesPressed = jest.fn()
  let tree = renderer.create(
    <CourseCard {...defaultProps} onCoursePreferencesPressed={onCoursePreferencesPressed} />
  ).toJSON()

  let button = explore(tree).selectByID(`CourseCardCell.${defaultProps.course.id}.optionsButton`) || {}
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

it('shows lock icon for grade if needed', () => {
  let course = courseTemplate.course({
    enrollments: [{
      enrollment_state: 'active',
      role: 'StudentEnrollment',
      role_id: '1',
      type: 'student',
      user_id: '1',
      has_grading_periods: true,
      totals_for_all_grading_periods_option: false,
      current_grading_period_id: null,
    }],
  })
  const tree = shallow(<CourseCard {...defaultProps} course={course} showGrade />)
  expect(tree.find('[testID="course-1-grades-locked"]').prop('source')).toEqual({
    uri: 'lockSolid',
  })
})
