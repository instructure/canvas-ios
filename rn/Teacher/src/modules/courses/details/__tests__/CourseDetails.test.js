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
import { CourseDetails, Refreshed } from '../CourseDetails'
import App from '../../../app'

const template = {
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/tab'),
  ...require('../../../../__templates__/helm'),
}

jest
  .mock('../../../../routing')

const course = template.course()

const defaultProps = {
  navigator: template.navigator(),
  course,
  tabs: [template.tab()],
  courseColors: template.customColors(),
  courseID: course.id,
  refreshing: false,
}

describe('CourseDetails', () => {
  it('renders correctly', () => {
    const tree = shallow(<CourseDetails {...defaultProps} />)
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
    const tree = shallow(<CourseDetails {...defaultProps} tabs={[]} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders without course', () => {
    const props = { ...defaultProps, course: null }
    expect(shallow(<CourseDetails {...props} />)).toMatchSnapshot()
  })

  it('go back to course list', () => {
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        dismiss: jest.fn(() => Promise.resolve()),
      }),
    }
    const tree = shallow(<CourseDetails {...props} />)
    tree.instance().back()
    expect(props.navigator.dismiss).toHaveBeenCalled()
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

    const tree = shallow(<CourseDetails {...props} />)
    tree
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.assignments"]')
      .simulate('Press', tab)
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/12/assignments')
  })

  it('launches external tool tab', () => {
    const currentApp = App.current()
    App.setCurrentApp('student')

    let url = 'https://canvas.instructure.com/courses/1/sessionless_launch?url=blah'
    const tab = template.tab({
      id: 'external_tool_4',
      type: 'external',
      url,
    })
    const props = {
      ...defaultProps,
      tabs: [tab],
      navigator: template.navigator({
        launchExternalTool: jest.fn(),
      }),
    }

    const tree = shallow(<CourseDetails {...props} />)
    tree
      .find('OnLayout').first().dive()
      .find('[testID="courses-details.tab.external_tool_4"]')
      .simulate('Press', tab)
    expect(props.navigator.launchExternalTool).toHaveBeenCalledWith(url)

    App.setCurrentApp(currentApp.appId)
  })

  it('can edit course', () => {
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }
    const tree = shallow(<CourseDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/settings',
      { modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('renders with image url', () => {
    const course = template.course({ image_download_url: 'http://www.fillmurray.com/100/100' })
    expect(shallow(<CourseDetails {...defaultProps} course={course} />))
      .toMatchSnapshot()
  })

  it('renders without image url', () => {
    const course = template.course({ image_download_url: null })
    expect(shallow(<CourseDetails {...defaultProps} course={course} />))
      .toMatchSnapshot()
  })

  it('renders with empty image url', () => {
    const course = template.course({ image_download_url: '' })
    expect(shallow(<CourseDetails {...defaultProps} course={course} />))
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
    shallow(<CourseDetails {...props} />)
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
    shallow(<CourseDetails {...props} />)
    expect(navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/placeholder',
      {},
      { course },
    )
  })
})
