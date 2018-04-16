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

import { shallow } from 'enzyme'
import React from 'react'
import { CourseNavigation, Refreshed, mapStateToProps } from '../CourseNavigation'
import App from '../../app'
import * as LTITools from '../../../common/LTITools'

const template = {
  ...require('../../../__templates__/course'),
  ...require('../../../__templates__/tab'),
  ...require('../../../__templates__/helm'),
  ...require('../../../redux/__templates__/app-state'),
}

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
}

describe('CourseNavigation', () => {
  it('renders correctly', () => {
    const tree = shallow(<CourseNavigation {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('refreshes courses and tabs', () => {
    const refreshCourses = jest.fn()
    const refreshTabs = jest.fn()
    const refreshLTITools = jest.fn()
    const refreshProps = {
      navigator: template.navigator(),
      courseID: course.id,
      tabs: [],
      refreshCourses,
      refreshTabs,
      refreshLTITools,
    }

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshCourses).toHaveBeenCalled()
    expect(refreshTabs).toHaveBeenCalledWith(course.id)
  })

  it('refreshes when props change', () => {
    const refreshCourses = jest.fn()
    const refreshTabs = jest.fn()
    const refreshLTITools = jest.fn()
    const refreshProps = {
      navigator: template.navigator(),
      courseID: course.id,
      course,
      tabs: [],
      refreshCourses,
      refreshTabs,
      refreshLTITools,
    }

    const tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    tree.instance().refresh()
    tree.setProps(refreshProps)
    expect(refreshCourses).toHaveBeenCalled()
    expect(refreshTabs).toHaveBeenCalledWith(course.id)
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
    }

    const props = mapStateToProps(state, { courseID: '1' })

    expect(props).toEqual(expected)
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
    }

    const props = mapStateToProps(state, { courseID: '1' })

    expect(props).toEqual(expected)
  })

  describe('external tools', () => {
    function assertExternalToolTabs () {
      const course = template.course({ id: 1 })
      const tabs = { tabs: [template.tab({ id: 'context_external_tool_1234' })], pending: 0 }
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

      expect(props).toMatchObject({ tabs: tabs.tabs })
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
})
