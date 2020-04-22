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

import { shallow } from 'enzyme'
import React from 'react'
import renderer from 'react-test-renderer'
import {
  Dashboard,
  isCourseConcluded,
} from '../Dashboard'
import explore from '../../../../test/helpers/explore'
import App from '../../app/index'

import * as template from '../../../__templates__'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
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
  liveConferences: [],
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
  canActAsUser: false,
}

beforeAll(() => App.setCurrentApp('student'))
afterAll(() => App.setCurrentApp('teacher'))

describe('Dashboard', () => {
  beforeEach(() => {
    App.setCurrentApp('teacher')
  })

  it('render', () => {
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('render while pending', () => {
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} pending={1} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('render without favorite courses', () => {
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} courses={[]} totalCourseCount={3} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('render without courses and *zero* total courses', () => {
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} courses={[]} concludedCourses={[]} totalCourseCount={0} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('select profile', () => {
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }
    let tree = renderAndLayout(
      <Dashboard {...props} />
    ).toJSON()

    const leftButton = explore(tree).selectLeftBarButton('Dashboard.profileButton') || {}
    leftButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/profile', { modal: true, embedInNavigationController: false, modalPresentationStyle: 'drawer' })
  })

  it('select course', () => {
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

    const courseCard = explore(tree).selectByID('CourseCardCell.' + course.id) || {}
    courseCard.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1')
  })

  it('opens course preferences', () => {
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

    const kabob = explore(tree).selectByID(`CourseCardCell.${course.id}.optionsButton`) || {}
    kabob.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/user_preferences',
      { modal: true },
    )
  })

  it('go to all courses', () => {
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

  it('calls navigator.push when a course is selected', () => {
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

  it('calls navigator.show when the edit button is pressed', () => {
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

  it('Only renders courses when !isFullDashboard', () => {
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} isFullDashboard={false} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('Doesnt render groups when in the teacher app', () => {
    App.setCurrentApp('teacher')
    let tree = renderAndLayout(
      <Dashboard {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
    App.setCurrentApp('student')
  })

  it('calls navigator.show when a group is pressed', () => {
    let navigator = template.navigator({
      show: jest.fn(),
    })

    let tree = renderAndLayout(
      <Dashboard {...defaultProps} navigator={navigator} />
    )
    tree.getInstance().showGroup('1')
    expect(navigator.show).toHaveBeenCalledWith('/groups/1')
  })

  it('calls navigator.show to navigate to /wrong-app', () => {
    let navigator = template.navigator({
      show: jest.fn(),
    })
    let props = {
      ...defaultProps,
      totalCourseCount: 0,
      navigator,
    }
    let tree = renderAndLayout(
      <Dashboard {...props} />
    )

    tree.getInstance().componentWillReceiveProps(props)
    expect(navigator.show).toHaveBeenCalledWith('/wrong-app', {
      modal: true,
      disableSwipeDownToDismissModal: true,
    })
  })

  it('does not call navigator.show to navigate to /wrong-app when canActAsUser', () => {
    let navigator = template.navigator({
      show: jest.fn(),
    })

    let props = {
      ...defaultProps,
      canActAsUser: true,
      totalCourseCount: 0,
      navigator,
    }

    let tree = renderAndLayout(
      <Dashboard {...props} />
    )

    tree.getInstance().componentWillReceiveProps(props)
    expect(navigator.show).not.toHaveBeenCalled()
  })

  it('only calls navigator.show to navigate to /wrong-app when in teacher app', () => {
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

  it('renders course invites', () => {
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

  it('filters invites restricted by date', async () => {
    let currentApp = App.current().appId
    App.setCurrentApp('student')

    const course1 = template.course({
      id: '1',
      access_restricted_by_date: true,
    })
    const course2 = template.course({ id: '2' })
    const allCourses = {
      [course1.id]: course1,
      [course2.id]: course2,
    }
    const courses = [course1, course2]

    const enrollments = [
      template.enrollment({
        id: '1',
        course_id: course1.id,
        enrollment_state: 'invited',
      }),
      template.enrollment({
        id: '2',
        course_id: course2.id,
        enrollment_state: 'invited',
      }),
    ]

    let props = {
      ...defaultProps,
      enrollments,
      allCourses,
      courses,
      sections,
    }

    let screen = shallow(<Dashboard {...props} />)
    const layout = { width: 340, height: 400 }
    screen.find('SectionList').simulate('Layout', { nativeEvent: { layout } })
    await screen.update()
    const sections = screen.find('SectionList').prop('sections')
    const inviteSection = sections[1]
    expect(inviteSection.data).toHaveLength(1)
    expect(inviteSection.data[0].id).toEqual('2')

    App.setCurrentApp(currentApp)
  })

  it('handles accept invite', () => {
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

    const courseInvite = explore(tree).selectByID('CourseInvitation.1.acceptButton') || {}
    courseInvite.props.onPress()
    expect(props.acceptEnrollment).toHaveBeenCalledWith('4', '1')
    App.setCurrentApp(currentApp)
  })

  it('handles reject invite', () => {
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

    const courseInvite = explore(tree).selectByID('CourseInvitation.1.rejectButton') || {}
    courseInvite.props.onPress()
    expect(props.rejectEnrollment).toHaveBeenCalledWith('4', '1')
    App.setCurrentApp(currentApp)
  })

  it('centers courses empty state in center of screen without groups', async () => {
    const props = {
      ...defaultProps,
      courses: [],
    }

    const screenHeight = 400
    const headerHeight = 60
    const offsetY = 40
    const expectedHeight = screenHeight - headerHeight - offsetY

    const screen = shallow(<Dashboard {...props} />)
    const list = screen.find('SectionList')
    const layout = { width: 340, height: screenHeight }
    list.simulate('Layout', { nativeEvent: { layout } })
    await screen.update()

    const section = () => {
      const sections = screen.find('SectionList').prop('sections')
      return shallow(sections[2].renderItem())
    }

    screen.instance().noCourses = {
      measure: jest.fn((callback) => callback(0, 0, 0, 0, 0, offsetY)),
    }
    section().simulate('Layout')
    await screen.update()
    const noCourses = section().find('NoCourses')
    expect(noCourses.prop('style')).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          height: expectedHeight,
        }),
      ])
    )
  })

  it('centers courses empty state in percentage of screen with groups', async () => {
    App.setCurrentApp('student')
    const props = {
      ...defaultProps,
      courses: [],
      groups,
    }

    const screenHeight = 100
    const expectedHeight = 70

    const screen = shallow(<Dashboard {...props} />)
    const list = screen.find('SectionList')
    const layout = { width: 340, height: screenHeight }
    list.simulate('Layout', { nativeEvent: { layout } })
    await screen.update()

    const section = () => {
      const sections = screen.find('SectionList').prop('sections')
      return shallow(sections[2].renderItem())
    }

    section().simulate('Layout') // for code coverage
    await screen.update()
    const noCourses = section().find('NoCourses')
    expect(noCourses.prop('style')).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          height: expectedHeight,
        }),
      ])
    )
  })
})

describe('isCourseConcluded', () => {
  it('determines if a course is concluded or not', () => {
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
})
