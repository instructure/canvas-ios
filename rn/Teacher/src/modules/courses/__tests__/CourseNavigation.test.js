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
import React from 'react'
import {
  Linking,
  NativeModules,
  Alert,
} from 'react-native'
import { CourseNavigation, Refreshed, mapStateToProps } from '../CourseNavigation'
import App from '../../app'
import * as LTITools from '../../../common/LTITools'
import * as template from '../../../__templates__/'

const { NativeLogin } = NativeModules

jest
  .mock('../../../routing')
  .mock('../../../common/LTITools.js', () => ({
    launchExternalTool: jest.fn(),
  }))

const course = template.course()

const defaultProps = {
  navigator: template.navigator(),
  course,
  tabs: [template.tab()],
  courseColors: template.customColors(),
  courseID: course.id,
  refreshing: false,
  showColorOverlay: true,
}

describe('CourseNavigation', () => {
  beforeEach(() => {
    App.setCurrentApp('teacher')
  })

  it('renders correctly', () => {
    const tree = shallow(<CourseNavigation {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('refreshes courses and tabs', () => {
    const refreshCourse = jest.fn()
    const refreshTabs = jest.fn()
    const refreshLTITools = jest.fn()
    const getUserSettings = jest.fn()
    const getCoursePermissions = jest.fn()
    const refreshProps = {
      navigator: template.navigator(),
      courseID: course.id,
      tabs: [],
      refreshCourse,
      refreshTabs,
      refreshLTITools,
      getUserSettings,
      getCoursePermissions,
    }

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshCourse).toHaveBeenCalledWith(course.id)
    expect(refreshTabs).toHaveBeenCalledWith(course.id)
    expect(getUserSettings).toHaveBeenCalled()
    expect(getCoursePermissions).toHaveBeenCalledWith(course.id)
  })

  it('refreshes when props change', () => {
    const refreshCourse = jest.fn()
    const refreshTabs = jest.fn()
    const refreshLTITools = jest.fn()
    const getUserSettings = jest.fn()
    const getCoursePermissions = jest.fn()
    const refreshProps = {
      navigator: template.navigator(),
      courseID: course.id,
      course,
      tabs: [],
      refreshCourse,
      refreshTabs,
      refreshLTITools,
      getUserSettings,
      getCoursePermissions,
    }

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    tree.instance().refresh()
    tree.setProps(refreshProps)
    expect(refreshCourse).toHaveBeenCalled()
    expect(refreshTabs).toHaveBeenCalledWith(course.id)
    expect(getUserSettings).toHaveBeenCalled()
    expect(getCoursePermissions).toHaveBeenCalledWith(course.id)
  })

  it('renders correctly without tabs', () => {
    const tree = shallow(<CourseNavigation {...defaultProps} tabs={[]} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders without course', () => {
    const props = { ...defaultProps, course: null }
    expect(shallow(<CourseNavigation {...props} />)).toMatchSnapshot()
  })

  it('selects tab', () => {
    const tab = template.tab({
      id: 'assignments',
      html_url: '/courses/12/assignments',
    })
    const props = {
      ...defaultProps,
      course: template.course({ id: 12 }),
      tabs: [tab],
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.assignments"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/12/assignments')
  })

  describe('lti launch', () => {
    function assertLTILaunch () {
      let url = 'https://canvas.instructure.com/courses/1/sessionless_launch?url=blah'
      const tab = template.tab({
        id: 'external_tool_4',
        type: 'external',
        url,
      })
      const props = {
        ...defaultProps,
        tabs: [tab],
        navigator: template.navigator(),
      }

      const tree = shallow(<CourseNavigation {...props} />)
      tree
        .find('TabsList').first().dive()
        .find('OnLayout').first().dive()
        .find('[testID="courses-details.tab.external_tool_4"]')
        .simulate('Press', tab)
      expect(LTITools.launchExternalTool).toHaveBeenCalledWith(url)
    }

    it('launches from student', () => {
      const currentApp = App.current()
      App.setCurrentApp('student')
      assertLTILaunch()
      App.setCurrentApp(currentApp.appId)
    })

    it('launches from teacher', () => {
      const currentApp = App.current()
      App.setCurrentApp('teacher')
      assertLTILaunch()
      App.setCurrentApp(currentApp.appId)
    })
  })

  it('can edit course', () => {
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }
    const tree = shallow(<CourseNavigation {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/settings',
      { modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('renders with image url', () => {
    const course = template.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
    expect(shallow(<CourseNavigation {...defaultProps} course={course} />))
      .toMatchSnapshot()
  })

  it('renders without image url', () => {
    const course = template.course({ image_download_url: null })
    expect(shallow(<CourseNavigation {...defaultProps} course={course} />))
      .toMatchSnapshot()
  })

  it('renders with empty image url', () => {
    const course = template.course({ image_download_url: '' })
    expect(shallow(<CourseNavigation {...defaultProps} course={course} />))
      .toMatchSnapshot()
  })

  it('shows home tab', async () => {
    const navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
    })
    const props = {
      ...defaultProps,
      tabs: [template.tab({ id: 'home' })],
      navigator,
    }
    shallow(<CourseNavigation {...props} />)
    await Promise.resolve() // wait for next run loop
    expect(navigator.show).toHaveBeenLastCalledWith(props.tabs[0].html_url)
  })

  it('shows placeholder if no home tab', () => {
    const navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
    })
    const props = {
      ...defaultProps,
      navigator,
    }
    shallow(<CourseNavigation {...props} />)
    expect(navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/placeholder',
      {},
      { course },
    )
  })

  it('navigates to wiki home page', async () => {
    const currentApp = App.current()
    App.setCurrentApp('student')
    const navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
    })
    const props = {
      ...defaultProps,
      course: template.course({ default_view: 'wiki' }),
      tabs: [template.tab({ id: 'home' })],
      navigator,
    }
    shallow(<CourseNavigation {...props} />)
    await Promise.resolve() // wait for next run loop
    expect(navigator.show).toHaveBeenLastCalledWith(`/courses/${props.course.id}/pages/front_page`)
    App.setCurrentApp(currentApp.appId)
  })

  it('navigates to pages list when selecting pages tab', () => {
    const tab = template.tab({
      id: 'pages',
      html_url: '/courses/1/wiki',
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.pages"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/pages')
  })

  it('navigates to syllabus', () => {
    const tab = template.tab({
      id: 'syllabus',
      html_url: '/courses/1/syllabus',
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.syllabus"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/syllabus')
  })

  it('navigates to conferences', () => {
    const tab = template.tab({
      id: 'conferences',
      full_url: 'https://canvas.instructure.com/courses/1/conferences',
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.conferences"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith(tab.full_url)
  })

  it('shows collaborations in a web view', () => {
    const tab = template.tab({
      id: 'collaborations',
      full_url: 'https://canvas.instructure.com/courses/1/collaborations',
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        showWebView: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.collaborations"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith(tab.full_url)
  })

  it('shows outcomes', () => {
    const tab = template.tab({
      id: 'outcomes',
      full_url: 'https://canvas.instructure.com/courses/1/outcomes',
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        showWebView: jest.fn(),
      }),
    }

    const tree = shallow(<CourseNavigation {...props} />)
    tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.outcomes"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith(tab.full_url)
  })

  it('launches Student View', async () => {
    Linking.canOpenURL = jest.fn(() => Promise.resolve(true))
    NativeLogin.actAsFakeStudentWithID = jest.fn()
    let tab = template.tab({ id: 'student-view' })
    let props = {
      ...defaultProps,
      tabs: [ tab ],
      getFakeStudent: jest.fn(() => Promise.resolve({
        data: { id: '22' },
      })),
    }
    let tree = shallow(<CourseNavigation {...props} />)
    await tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.student-view"]')
      .simulate('Press', tab)
    await new Promise((resolve) => process.nextTick(resolve))
    expect(NativeLogin.actAsFakeStudentWithID).toHaveBeenCalledWith('22')
  })

  it('shows alert without fake student when launching student view', async () => {
    Alert.alert = jest.fn()
    let tab = template.tab({ id: 'student-view' })
    let props = {
      ...defaultProps,
      tabs: [ tab ],
      getFakeStudent: jest.fn(() => Promise.resolve({
        data: null,
      })),
    }
    let tree = shallow(<CourseNavigation {...props} />)
    await tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.student-view"]')
      .simulate('Press', tab)
    await new Promise((resolve) => process.nextTick(resolve))
    expect(Alert.alert).toHaveBeenCalledWith(
      'Error',
      'Please try again.',
      [ { text: 'OK', onPress: null, style: 'cancel' } ]
    )
  })

  it('opens App Store url if student app is not installed', async () => {
    Linking.openURL = jest.fn()
    Linking.canOpenURL = jest.fn(() => Promise.resolve(false))
    NativeLogin.actAsFakeStudentWithID = jest.fn()
    let tab = template.tab({ id: 'student-view' })
    let props = {
      ...defaultProps,
      tabs: [ tab ],
      getFakeStudent: jest.fn(() => Promise.resolve({
        data: { id: '22' },
      })),
    }
    let tree = shallow(<CourseNavigation {...props} />)
    await tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.student-view"]')
      .simulate('Press', tab)
    await new Promise((resolve) => process.nextTick(resolve))
    expect(Linking.openURL).toHaveBeenCalledWith('https://apps.apple.com/us/app/canvas-student/id480883488')
  })

  it('shows alert if fake student request fails', async () => {
    Alert.alert = jest.fn()
    let tab = template.tab({ id: 'student-view' })
    let props = {
      ...defaultProps,
      tabs: [ tab ],
      getFakeStudent: jest.fn(() => Promise.reject({})),
    }
    let tree = shallow(<CourseNavigation {...props} />)
    await tree
      .find('TabsList').first().dive()
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.student-view"]')
      .simulate('Press', tab)
    await new Promise((resolve) => process.nextTick(resolve))
    expect(Alert.alert).toHaveBeenCalledWith(
      'Error',
      'Please try again.',
      [ { text: 'OK', onPress: null, style: 'cancel' } ]
    )
  })
})

describe('mapStateToProps', () => {
  beforeEach(() => {
    App.setCurrentApp('teacher')
  })

  it('returns the correct props', () => {
    const course = template.course({ id: 1 })
    const tabs = { tabs: [template.tab()], pending: 0 }
    const attendanceTool = { pending: 0 }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool,
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })
    const expected = {
      course,
      tabs: tabs.tabs,
      color: '#fff',
      pending: 0,
      error: undefined,
      showColorOverlay: true,
    }

    const props = mapStateToProps(state, { courseID: '1' })

    expect(props).toEqual(expected)
  })

  it('returns the correct showColorOverlay', () => {
    let course = template.course({ image_download_url: 'https://google.com' })
    const tabs = { tabs: [template.tab()], pending: 0 }
    const attendanceTool = { pending: 0 }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool,
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
      userInfo: {
        userSettings: {},
      },
    })

    expect(mapStateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)

    state.userInfo.userSettings.hide_dashcard_color_overlays = true
    expect(mapStateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(false)

    state.userInfo.userSettings.hide_dashcard_color_overlays = false
    expect(mapStateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)

    state.userInfo.userSettings.hide_dashcard_color_overlays = true
    state.entities.courses['1'].course.image_download_url = null
    expect(mapStateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)
  })

  it('returns basic props without course', () => {
    const state: { [string]: any } = {
      entities: {
        courses: {},
      },
      favoriteCourses: {},
    }

    expect(
      mapStateToProps(state, { courseID: '1' })
    ).toEqual({
      pending: 0,
      tabs: [],
      course: null,
      color: '',
      attendanceTabID: null,
      showColorOverlay: true,
    })
  })

  it('hides attendance tab if it is hidden', () => {
    const course = template.course({ id: '1' })
    const tabs = { tabs: [template.tab({ id: '1', hidden: true })], pending: 0 }
    const attendanceTool = { tabID: '1', pending: 0 }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool,
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })
    const expected = {
      course,
      tabs: [],
      color: '#fff',
      pending: 0,
      error: undefined,
      attendanceTabID: '1',
      showColorOverlay: true,
    }

    const props = mapStateToProps(state, { courseID: '1' })

    expect(props).toEqual(expected)
  })

  it('excludes hidden tabs in student', () => {
    App.setCurrentApp('student')
    const course = template.course({ id: '1' })
    const tabs = { tabs: [template.tab({ id: '1', hidden: true })], pending: 0 }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool: { pending: 0 },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })
    const props = mapStateToProps(state, { courseID: '1' })
    expect(props).toMatchObject({ tabs: [] })
  })

  it('includes hidden tabs in teacher', () => {
    App.setCurrentApp('teacher')
    const course = template.course({ id: '1' })
    const tab = template.tab({ id: 'files', hidden: true })
    const tabs = { tabs: [tab], pending: 0 }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool: { pending: 0 },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })
    const props = mapStateToProps(state, { courseID: '1' })
    expect(props).toMatchObject({ tabs: [tab] })
  })

  it('includes modules in student', () => {
    App.setCurrentApp('student')
    const course = template.course({ id: 1 })
    const tabs = {
      tabs: [
        template.tab({ id: 'modules' }),
      ],
      pending: 0,
    }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool: { pending: 0 },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })

    const props = mapStateToProps(state, { courseID: '1' })
    expect(props).toMatchObject({ tabs: [{ id: 'modules' }] })
  })

  it('includes modules in teacher', () => {
    App.setCurrentApp('teacher')
    const course = template.course({ id: 1 })
    const tabs = {
      tabs: [
        template.tab({ id: 'modules' }),
      ],
      pending: 0,
    }
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs,
            attendanceTool: { pending: 0 },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })

    const props = mapStateToProps(state, { courseID: '1' })
    expect(props).toMatchObject({ tabs: [{ id: 'modules' }] })
  })

  describe('external tools', () => {
    function assertExternalToolTabs () {
      const course = template.course({ id: 1 })
      const tabs = {
        tabs: [
          template.tab({ id: 'context_external_tool_1234' }),
          template.tab({ id: 'context_external_tool_12345', hidden: true }),
        ],
        pending: 0,
      }
      const state = template.appState({
        entities: {
          courses: {
            '1': {
              course,
              color: '#fff',
              tabs,
              attendanceTool: { pending: 0 },
            },
          },
        },
        favoriteCourses: {
          pending: 0,
          courseRefs: ['1'],
        },
      })

      const props = mapStateToProps(state, { courseID: '1' })

      expect(props).toMatchObject({ tabs: [tabs.tabs[0]] })
    }

    it('includes them in student', () => {
      App.setCurrentApp('student')
      assertExternalToolTabs()
    })

    it('includes them in teacher', () => {
      App.setCurrentApp('teacher')
      assertExternalToolTabs()
    })
  })

  it('includes Student View tab in teacher with permission', () => {
    App.setCurrentApp('teacher')
    let tabs = [ template.tab({ id: 'modules' }) ]
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs: { tabs, pending: 0 },
            attendanceTool: { pending: 0 },
            permissions: { use_student_view: true },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })

    const props = mapStateToProps(state, { courseID: '1' })
    let studentViewTab = props.tabs.slice(-1)[0] // should be the last item
    expect(studentViewTab.id).toEqual('student-view')
  })

  it('does not include Student View in teacher without correct permission', () => {
    App.setCurrentApp('teacher')
    let tabs = [ template.tab({ id: 'modules' }) ]
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs: { tabs, pending: 0 },
            attendanceTool: { pending: 0 },
            permissions: { use_student_view: false },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })

    const props = mapStateToProps(state, { courseID: '1' })
    expect(props.tabs.map(t => t.id)).not.toContain('student-view')
  })

  it('does not include Student View tab in student', () => {
    App.setCurrentApp('student')
    let tabs = [ template.tab({ id: 'modules' }) ]
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course,
            color: '#fff',
            tabs: { tabs, pending: 0 },
            attendanceTool: { pending: 0 },
            permissions: { use_student_view: true },
          },
        },
      },
      favoriteCourses: {
        pending: 0,
        courseRefs: ['1'],
      },
    })

    const props = mapStateToProps(state, { courseID: '1' })
    expect(props.tabs.map(t => t.id)).not.toContain('student-view')
  })
})
