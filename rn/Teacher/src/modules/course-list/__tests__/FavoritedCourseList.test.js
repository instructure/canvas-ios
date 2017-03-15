/* @flow */

import 'react-native'
import React from 'react'
import { FavoritedCourseList } from '../FavoritedCourseList.js'
import explore from '../../../../test/helpers/explore'
import { route } from '../../../routing'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('../../../routing')

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
  const course = template.course({ id: 1, is_favorite: true })
  const props = {
    ...defaultProps,
    courses: [course],
    navigator: template.navigator({
      push: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <FavoritedCourseList {...props} />
  ).toJSON()

  const courseCard = explore(tree).selectByID(course.course_code) || {}
  courseCard.props.onPress()
  expect(props.navigator.push).toHaveBeenCalledWith(route('/courses/1'))
})

test('go to all courses', () => {
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      push: jest.fn(),
    }),
  }
  let tree = renderer.create(
    <FavoritedCourseList {...props} />
  ).toJSON()

  const allButton = explore(tree).selectByID('course-list.see-all-btn') || {}
  allButton.props.onPress()
  expect(props.navigator.push).toHaveBeenCalledWith({
    ...route('/courses'),
    title: 'All Courses',
    backButtonTitle: 'Courses',
  })
})

test('calls navigator.push when a course is selected', () => {
  const course = template.course({ id: 1 })
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      push: jest.fn(),
    }),
    courses: [course],
  }
  let tree = renderer.create(
    <FavoritedCourseList {...props} />
  ).toJSON()

  let button: any = explore(tree).selectByID(course.course_code)
  button.props.onPress()

  expect(props.navigator.push).toHaveBeenLastCalledWith(route('/courses/1'))
})

test('calls navigator.showModal when the edit button is pressed', () => {
  let navigator = template.navigator({
    showModal: jest.fn(),
  })
  let tree = renderer.create(
    <FavoritedCourseList {...defaultProps} navigator={navigator} />
  )

  tree._component._renderedComponent._instance.onNavigatorEvent({
    type: 'NavBarButtonPress',
    id: 'edit',
  })

  expect(navigator.showModal).toHaveBeenCalledWith({
    ...route('/course_favorites'),
    animationType: 'slide-up',
    title: 'Edit Courses',
  })
})

test('beta feedback button exists', () => {
  expect(FavoritedCourseList.navigatorButtons.leftButtons).toMatchObject([{
    title: 'Leave Feedback',
    id: 'beta-feedback',
  }])
})

test('press beta feedback button presents feedback modally', () => {
  let navHandler = () => {}
  const event = {
    type: 'NavBarButtonPress',
    id: 'beta-feedback',
  }
  const props = {
    ...defaultProps,
    navigator: template.navigator({
      showModal: jest.fn(),
      setOnNavigatorEvent: (callback) => { navHandler = callback },
    }),
  }

  renderer.create(
    <FavoritedCourseList {...props} />
  )

  navHandler(event)

  expect(props.navigator.showModal).toHaveBeenCalledWith(route('/beta-feedback'))
})
