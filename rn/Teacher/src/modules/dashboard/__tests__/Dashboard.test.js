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

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import {
  Dashboard,
  isCourseConcluded,
} from '../Dashboard'
import explore from '../../../../test/helpers/explore'
import App from '../../app/index'

import * as template from '../../../__templates__'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../routing/Screen')

const colors = {
  '1': '#27B9CD',
  '2': '#8F3E97',
  '3': '#8F3E99',
}

function renderAndLayout (dashboard) {
  const r = renderer.create(dashboard)
  r.getInstance().setState({ width: 375, contentWidth: 359, cardWidth: 179 })
  return r
}

const course1 = template.course({
  name: 'Biology 101',
  course_code: 'BIO 101',
  short_name: 'BIO 101',
  id: '1',
  is_favorite: true,
})
const course2 = template.course({
  name: 'American Literature Psysicks foobar hello world 401',
  course_code: 'LIT 401',
  short_name: 'LIT 401',
  id: '2',
  is_favorite: false,
})
const course3 = template.course({
  name: 'Foobar 102',
  course_code: 'FOO 102',
  id: '3',
  short_name: 'FOO 102',
  is_favorite: true,
})

const course4 = template.course({
  name: 'Foobar 102',
  course_code: 'FOO 102',
  id: '4',
  short_name: 'FOO 102',
  workflow_state: 'completed',
})

const courses = [
  course1,
  course2,
  course3,
].map(course => ({ ...course, color: colors[course.id] }))

const concludedCourses = [
  course4,
].map(course => ({ ...course, color: colors[course.id] }))

const allCourses = {
  '1': course1,
  '2': course2,
  '3': course3,
  '4': template.course({ id: '4' }),
  '5': template.course({ id: '5' }),
}

const groups = [{
  id: '1',
  name: 'Group 1',
  contextName: 'Biology 101',
  term: 'Bio-101',
  color: '#27B9CD',
}, {
  id: '2',
  name: 'Group 2',
  contextName: 'American Literature Psysicks foobar hello world 401',
  color: '#8F3E99',
}]

const enrollments = [
  template.enrollment({
    id: '1',
    course_id: '4',
    enrollment_state: 'invited',
    course_section_id: '1',
  }),
  template.enrollment({
    id: '2',
    course_id: '5',
    enrollment_state: 'invited',
    course_section_id: '2',
  }),
]

const sections = {
  '1': template.section({ id: '1', course_id: '4' }),
  '2': template.section({ id: '2', course_id: '5' }),
}

let defaultProps = {
  navigator: template.navigator(),
  courses,
  concludedCourses,
  enrollments: [],
  sections: {},
  allCourses: {},
  announcements: [],
  customColors: colors,
  refreshCourses: () => {},
  pending: 0,
  refresh: jest.fn(),
  refreshing: false,
  totalCourseCount: courses.length,
  isFullDashboard: true,
  closeNotification () {},
  groups,
}

beforeAll(() => App.setCurrentApp('student'))
afterAll(() => App.setCurrentApp('teacher'))

test('render', () => {
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render while pending', () => {
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} pending={1} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render without favorite courses', () => {
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} courses={[]} totalCourseCount={3} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render without courses and *zero* total courses', () => {
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} courses={[]} concludedCourses={[]} totalCourseCount={0} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('select profile', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const leftButton = explore(tree).selectLeftBarButton('favorited-course-list.profile-btn') || {}
  leftButton.action()
  expect(props.navigator.show).toHaveBeenCalledWith('/profile', { modal: true, modalPresentationStyle: 'drawer' })
})

test('select course', () => {
  const course = { ...template.course({ id: '1', is_favorite: true }), color: '#112233' }
  const props = {
    ...defaultProps,
    courses: [course],
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const courseCard = explore(tree).selectByID('course-' + course.id) || {}
  courseCard.props.onPress()
  expect(props.navigator.show).toHaveBeenCalledWith('/courses/1')
})

test('opens course preferences', () => {
  const course = template.course({ id: '1', is_favorite: true })
  const props = {
    ...defaultProps,
    courses: [{ ...course, color: '#fff' }],
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const kabob = explore(tree).selectByID(`course-card.kabob-${course.id}`) || {}
  kabob.props.onPress()
  expect(props.navigator.show).toHaveBeenCalledWith(
    '/courses/1/user_preferences',
    { modal: true },
  )
})

test('go to all courses', () => {
  const course = template.course({ id: '1', is_favorite: true })
  const props = {
    ...defaultProps,
    courses: [{ ...course, color: '#fff' }],
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const allButton = explore(tree).selectByID('dashboard.courses.see-all-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.show).toHaveBeenCalledWith('/courses')
})

test('calls navigator.push when a course is selected', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      show: jest.fn(),
    }),
  }
  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const allButton = explore(tree).selectByID('dashboard.courses.see-all-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.show).toHaveBeenCalledWith('/courses')
})

test('calls navigator.show when the edit button is pressed', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} navigator={navigator} />
  )

  tree.getInstance().showFavoritesList()
  expect(navigator.show).toHaveBeenCalledWith(
    '/course_favorites',
    { modal: true }
  )
})

test('Only renders courses when !isFullDashboard', () => {
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} isFullDashboard={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Doesnt render groups when in the teacher app', () => {
  App.setCurrentApp('teacher')
  let tree = renderAndLayout(
    <Dashboard {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
  App.setCurrentApp('student')
})

test('calls navigator.show when a group is pressed', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })

  let tree = renderAndLayout(
    <Dashboard {...defaultProps} navigator={navigator} />
  )
  tree.getInstance().showGroup('1')
  expect(navigator.show).toHaveBeenCalledWith('/groups/1')
})

test('only calls navigator.show to navigate to /notATeacher when in teacher app', () => {
  let currentApp = App.current().appId

  App.setCurrentApp('student')
  let props = {
    ...defaultProps,
    totalCourseCount: 0,
  }
  let navigator = template.navigator({
    show: jest.fn(),
  })

  let tree = renderAndLayout(
    <Dashboard {...props} navigator={navigator} />
  )

  tree.getInstance().componentWillReceiveProps(props)
  expect(navigator.show).not.toHaveBeenCalled()

  App.setCurrentApp(currentApp)
})

test('renders course invites', () => {
  let currentApp = App.current().appId

  App.setCurrentApp('student')
  let props = {
    ...defaultProps,
    enrollments,
    allCourses,
    sections,
  }

  let tree = renderAndLayout(
    <Dashboard {...props} />
  )
  expect(tree).toMatchSnapshot()
  App.setCurrentApp(currentApp)
})

test('handles accept invite', () => {
  let currentApp = App.current().appId

  App.setCurrentApp('student')
  let props = {
    ...defaultProps,
    enrollments,
    allCourses,
    sections,
    acceptEnrollment: jest.fn(),
  }

  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const courseInvite = explore(tree).selectByID('course-invite.1.accept-button') || {}
  courseInvite.props.onPress()
  expect(props.acceptEnrollment).toHaveBeenCalledWith('4', '1')
  App.setCurrentApp(currentApp)
})

test('handles accept invite', () => {
  let currentApp = App.current().appId

  App.setCurrentApp('student')
  let props = {
    ...defaultProps,
    enrollments,
    allCourses,
    sections,
    rejectEnrollment: jest.fn(),
  }

  let tree = renderAndLayout(
    <Dashboard {...props} />
  ).toJSON()

  const courseInvite = explore(tree).selectByID('course-invite.1.reject-button') || {}
  courseInvite.props.onPress()
  expect(props.rejectEnrollment).toHaveBeenCalledWith('4', '1')
  App.setCurrentApp(currentApp)
})

test('isCourseConcluded', () => {
  let course = template.course({ term: {} })
  expect(isCourseConcluded(course)).toEqual(false)

  course = template.course({ term: null })
  expect(isCourseConcluded(course)).toEqual(false)

  course = template.course({ term: { end_at: '2016-12-11T04:03:17Z' } })
  expect(isCourseConcluded(course)).toEqual(true)

  course = template.course({ end_at: '2016-12-11T04:03:17Z' })
  expect(isCourseConcluded(course)).toEqual(true)

  course = template.course({ workflow_state: 'available' })
  expect(isCourseConcluded(course)).toEqual(false)

  course = template.course({ workflow_state: 'completed' })
  expect(isCourseConcluded(course)).toEqual(true)
})
