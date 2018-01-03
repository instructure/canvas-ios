// @flow

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import {
  Dashboard,
} from '../Dashboard'
import explore from '../../../../test/helpers/explore'
import App from '../../app/index'

const template = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/group'),
  ...require('../../../__templates__/helm'),
}

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('TouchableHighlight', () => 'TouchableHighlight')

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

const courses = [
  template.course({
    name: 'Biology 101',
    course_code: 'BIO 101',
    short_name: 'BIO 101',
    id: '1',
    is_favorite: true,
  }),
  template.course({
    name: 'American Literature Psysicks foobar hello world 401',
    course_code: 'LIT 401',
    short_name: 'LIT 401',
    id: '2',
    is_favorite: false,
  }),
  template.course({
    name: 'Foobar 102',
    course_code: 'FOO 102',
    id: '3',
    short_name: 'FOO 102',
    is_favorite: true,
  }),
].map(course => ({ ...course, color: colors[course.id] }))

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

let defaultProps = {
  navigator: template.navigator(),
  courses,
  customColors: colors,
  refreshCourses: () => {},
  pending: 0,
  refresh: jest.fn(),
  refreshing: false,
  totalCourseCount: courses.length,
  isFullDashboard: true,
  groups,
}

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
    <Dashboard {...defaultProps} courses={[]} totalCourseCount={0} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
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
