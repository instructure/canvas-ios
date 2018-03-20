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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { Refreshed, AnnouncementsList, type Props, mapStateToProps } from '../AnnouncementsList'
import explore from '../../../../../test/helpers/explore'
import app from '../../../app'
import { shallow } from 'enzyme/build/index'

const template = {
  ...require('../../../../__templates__/discussion'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')

describe('AnnouncementsList', () => {
  let props: Props
  beforeEach(() => {
    jest.resetAllMocks()
    app.setCurrentApp('teacher')
    props = {
      context: 'courses',
      contextID: '1',
      refreshing: false,
      refresh: jest.fn(),
      pending: 0,
      error: null,
      navigator: template.navigator(),
      announcements: [
        template.discussion({
          id: '1',
          title: 'Untitled',
          posted_at: '2013-11-14T16:55:00-07:00',
        }),
        template.discussion({
          id: '2',
          title: 'Getting Started in Biology 101',
          posted_at: '2013-10-28T14:16:00-07:00',
        }),
      ],
      refreshAnnouncements: jest.fn(),
      refreshCourse: jest.fn(),
      courseName: 'Im a course',
      courseColor: 'blue',
      permissions: template.discussionPermissions(),
    }
  })

  it('refreshes when there are no announcements', () => {
    const refreshAnnouncements = jest.fn()
    const refreshCourse = jest.fn()
    const refreshProps = {
      announcements: [],
      refreshAnnouncements,
      refreshCourse,
    }

    let tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshAnnouncements).toHaveBeenCalled()
    expect(refreshCourse).toHaveBeenCalledTimes(0)

    // $FlowFixMe
    refreshProps.context = 'courses'
    tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshCourse).toHaveBeenCalledTimes(1)
  })

  it('refreshes when there are no permissions', () => {
    const refreshAnnouncements = jest.fn()
    const refreshProps = {
      announcements: [template.discussion({
        id: '1',
        title: 'Untitled',
        posted_at: '2013-11-14T16:55:00-07:00',
      })],
      permissions: {},
      refreshAnnouncements,
    }

    let tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    expect(refreshAnnouncements).toHaveBeenCalled()
  })

  it('refreshes with new props', () => {
    const refreshAnnouncements = jest.fn()
    const refreshProps = {
      announcements: [],
      permissions: {},
      refreshAnnouncements,
    }

    let tree = shallow(<Refreshed {...refreshProps} />)
    expect(tree).toMatchSnapshot()
    tree.instance().refresh()
    tree.setProps(refreshProps)
    expect(refreshAnnouncements).toHaveBeenCalledTimes(2)
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders with no create_announcement permission', () => {
    props.permissions.create_announcement = false
    testRender(props)
  })

  it('renders while pending', () => {
    props.announcements = []
    props.pending = 1
    testRender(props)
  })

  it('renders while refreshing', () => {
    props.pending = 1
    props.refreshing = true
    testRender(props)
  })

  it('renders empty list', () => {
    props.announcements = []
    testRender(props)
  })

  it('navigates to new announcement', () => {
    props.navigator.show = jest.fn()

    props.contextID = '2'
    tapAdd(render(props))
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/2/announcements/new',
      { modal: true },
    )
  })

  it('navigates to announcement when row tapped', () => {
    const announcement = template.discussion({ html_url: 'https://canvas.instructure.com/courses/1/discussions/2' })
    props.navigator.show = jest.fn()
    props.announcements = [announcement]
    const row: any = explore(render(props).toJSON()).selectByID('announcements.list.announcement.row-0')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(announcement.html_url, { modal: false }, {
      isAnnouncement: true,
    })
  })

  it('displays delayed post at date for delayed announcements', () => {
    const announcement = template.discussion({
      delayed_post_at: '3019-10-28T14:16:00-07:00',
      posted_at: '2017-10-27T14:16:00-07:00',
    })
    props.announcements = [announcement]
    const subtitle: any = explore(render(props).toJSON()).selectByID(`announcements.list.announcement.row-0.subtitle.custom-container`)
    expect(subtitle.children[0].children).toEqual(['Delayed until: '])
    expect(subtitle.children[1].children).toEqual(['Oct 28 at 3:16 PM'])
  })

  function testRender (props: any) {
    expect(render(props)).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(<AnnouncementsList {...props} />)
  }

  function tapAdd (component: any) {
    const addBtn: any = explore(component.toJSON()).selectRightBarButton('announcements.list.addButton')
    addBtn.action()
  }
})

describe('mapStateToProps', () => {
  it('maps course announcement refs to props', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const three = template.discussion({ id: '3' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '3'],
            },
            course: {
              name: 'CS 1010',
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
          '3': {
            data: three,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toEqual({
      announcements: [one, three],
      pending: 1,
      courseName: 'CS 1010',
      error: null,
    })
  })

  it('maps course announcement refs to props with group context', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const three = template.discussion({ id: '3' })
    const state = template.appState({
      entities: {
        groups: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '3'],
            },
            group: {
              name: 'CS 1010',
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
          '3': {
            data: three,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'groups', contextID: '1' })
    ).toEqual({
      announcements: [one, three],
      pending: 1,
      courseName: 'CS 1010',
      error: null,
      permissions: { create_announcement: true, create_discussion_topic: true },
    })
  })

  it('maps empty state', () => {
    const state = template.appState({
      entities: {},
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toEqual({
      announcements: [],
      courseName: '',
      courseColor: '',
      pending: 0,
      error: null,
      permissions: {},
    })
  })

  it('maps without course', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const three = template.discussion({ id: '3' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '3'],
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
          '3': {
            data: three,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toEqual({
      announcements: [one, three],
      pending: 1,
      courseName: '',
      courseColor: '',
      error: null,
    })
  })

  it('puts announcements in order', () => {
    const one = template.discussion({ id: '1', position: 1 })
    const two = template.discussion({ id: '2', position: 2 })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            announcements: {
              pending: 1,
              error: null,
              refs: ['1', '2'],
            },
            course: {
              name: 'CS 1010',
            },
          },
        },
        discussions: {
          '1': {
            data: one,
          },
          '2': {
            data: two,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toMatchObject({
      announcements: [two, one],
    })
  })
})
