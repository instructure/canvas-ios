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

import React from 'react'
import 'react-native'
import { Refreshed, AnnouncementsList, mapStateToProps } from '../AnnouncementsList'
import app from '../../../app'
import { shallow } from 'enzyme'
import * as template from '../../../../__templates__'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')

describe('AnnouncementsList', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
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

    shallow(<Refreshed {...refreshProps} />)
    expect(refreshAnnouncements).toHaveBeenCalled()
    expect(refreshCourse).toHaveBeenCalledTimes(0)

    refreshProps.context = 'courses'
    shallow(<Refreshed {...refreshProps} />)
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

    shallow(<Refreshed {...refreshProps} />)
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
    tree.instance().refresh()
    tree.setProps(refreshProps)
    expect(refreshAnnouncements).toHaveBeenCalledTimes(2)
  })

  it('renders with no create_announcement permission', () => {
    props.permissions.create_announcement = false
    let tree = shallow(<AnnouncementsList {...props} />)
    expect(tree.find('Screen').prop('rightBarButtons')).toBe(false)
  })

  it('renders while pending', () => {
    props.announcements = []
    props.pending = 1
    let tree = shallow(<AnnouncementsList {...props} />)
    expect(tree.find('ActivityIndicatorView').exists()).toBe(true)
  })

  it('renders while refreshing', () => {
    props.pending = 1
    props.refreshing = true
    let tree = shallow(<AnnouncementsList {...props} />)
    expect(tree.find('ActivityIndicatorView').exists()).toBe(false)
    expect(tree.find('FlatList').prop('refreshing')).toBe(true)
  })

  it('renders empty list', () => {
    props.announcements = []
    let tree = shallow(<AnnouncementsList {...props} />)
    expect(tree.find('FlatList').dive().find('ListEmptyComponent').prop('title'))
      .toBe('There are no announcements to display.')
  })

  it('navigates to new announcement', () => {
    props.contextID = '2'
    let tree = shallow(<AnnouncementsList {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/2/announcements/new',
      { modal: true },
    )
  })

  it('navigates to announcement when row tapped', () => {
    const announcement = template.discussion({ html_url: 'https://canvas.instructure.com/courses/1/discussions/2' })
    props.navigator.show = jest.fn()
    props.announcements = [announcement]
    let tree = shallow(<AnnouncementsList {...props} />)
    tree.find('FlatList').dive().find('Row').simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledWith(announcement.html_url, { modal: false }, {
      isAnnouncement: true,
    })
  })

  it('displays delayed post at date for delayed announcements', () => {
    const announcement = template.discussion({
      delayed_post_at: '3019-10-28T14:16:00-07:00',
      last_reply_at: '2017-10-27T14:16:00-07:00',
    })
    props.announcements = [announcement]
    let tree = shallow(<AnnouncementsList {...props} />)
    let subtitle = tree.find('FlatList').dive().find('[testID="announcements.list.announcement.row-0.subtitle.custom-container"]')
    expect(subtitle.find('[children^="Delayed until:"]').exists()).toBe(true)
    expect(subtitle.find('[children="Oct 28 at 3:16 PM"]').exists()).toBe(true)
  })

  it('displays last reply at date for regular announcements', () => {
    const announcement = template.discussion({
      delayed_post_at: null,
      last_reply_at: '2017-10-27T14:16:00-07:00',
    })
    props.announcements = [announcement]
    let tree = shallow(<AnnouncementsList {...props} />)
    let subtitle = tree.find('FlatList').dive().find('[testID="announcements.list.announcement.row-0.subtitle.custom-container"]')
    expect(subtitle.find('[children="Last post Oct 27 at 3:16 PM"]').exists()).toBe(true)
  })

  it('displays empty post date for announcements with no dates', () => {
    const announcement = template.discussion({
      delayed_post_at: null,
      last_reply_at: null,
    })
    props.announcements = [announcement]
    let tree = shallow(<AnnouncementsList {...props} />)
    let subtitle = tree.find('FlatList').dive().find('[testID="announcements.list.announcement.row-0.subtitle.custom-container"]')
    expect(subtitle.find('[children=""]').exists()).toBe(true)
  })
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
      courseName: null,
      courseColor: null,
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
      courseName: null,
      courseColor: null,
      error: null,
    })
  })

  it('puts announcements in order', () => {
    const one = template.discussion({ id: '1', posted_at: '2019-11-15T00:00:00Z' })
    const two = template.discussion({ id: '2', posted_at: '2019-11-16T00:00:00Z' })
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
