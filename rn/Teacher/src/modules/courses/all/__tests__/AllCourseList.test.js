/* @flow */

import 'react-native'
import React from 'react'
import { AllCourseList } from '../AllCourseList.js'
import explore from '../../../../../test/helpers/explore'
import type { CourseProps } from '../../course-prop-types'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('../../../../routing')

const template = {
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../__templates__/react-native-navigation'),
}

const colors = {
  '1': '#27B9CD',
  '2': '#8F3E97',
  '3': '#8F3E99',
}

const courses: Array<CourseProps> = [
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
].map(course => ({ ...course, color: colors[course.id] }))

let defaultProps = {
  navigator: template.navigator(),
  courses,
  pending: 0,
  refresh: jest.fn(),
  refreshing: false,
}

describe('AllCourseList', () => {
  beforeEach(() => jest.resetAllMocks())

  it('render', () => {
    let tree = renderer.create(
      <AllCourseList {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('sets its own title', () => {
    renderer.create(
      <AllCourseList {...defaultProps} />
    )
    expect(defaultProps.navigator.setTitle).toHaveBeenCalled()
  })

  it('select course', () => {
    const course: CourseProps = { ...template.course(), color: '#112233' }
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
    expect(props.navigator.push).toHaveBeenCalledWith({
      screen: '/courses/1',
    })
  })

  it('open course user prefs', () => {
    const showModal = jest.fn()
    const course: CourseProps = { ...template.course(), color: '#112233' }
    const props = {
      ...defaultProps,
      courses: [course],
      navigator: template.navigator({
        showModal,
      }),
    }
    let tree = renderer.create(
      <AllCourseList {...props} />
    ).getInstance()

    tree.openUserPreferences(course.id)
    expect(props.navigator.showModal).toHaveBeenCalledWith({
      screen: `/courses/${course.id}/user_preferences`,
      animationType: 'slide-up',
    })
  })
})

