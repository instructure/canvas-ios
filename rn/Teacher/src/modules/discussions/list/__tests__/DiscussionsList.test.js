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

import React from 'react'
import { ActionSheetIOS, Alert } from 'react-native'
import { shallow } from 'enzyme'

import { DiscussionsList, mapStateToProps, type Props } from '../DiscussionsList'
import app from '@modules/app'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing')
  .mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
    showActionSheetWithOptions: jest.fn(),
  }))
  .mock('../../../../routing/Screen')
  .mock('../../../app', () => ({
    isTeacher: jest.fn(),
    isStudent: jest.fn(),
  }))

const template = {
  ...require('@templates/helm'),
  ...require('@templates/discussion'),
  ...require('@redux/__templates__/app-state'),
}

describe('DiscussionsList', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    app.isTeacher = jest.fn(() => true)
    app.isStudent = jest.fn(() => false)
    props = {
      pending: false,
      refreshing: false,
      discussions: [],
      navigator: template.navigator(),
      courseColor: null,
      courseName: 'Course Name',
      updateDiscussion: jest.fn(),
      refreshDiscussions: jest.fn(),
      deleteDiscussion: jest.fn(),
      context: 'courses',
      contextID: '1',
      permissions: template.discussionPermissions(),
    }
  })

  it('renders an activity indicator while loading', () => {
    let tree = shallow(<DiscussionsList {...props} pending />)
    expect(tree.find('ActivityIndicatorView').exists()).toEqual(true)
  })

  it('uses the course color for the nav bar', () => {
    let tree = shallow(<DiscussionsList {...props} courseColor='#fff' />)
    expect(tree.find('Screen').prop('navBarColor')).toEqual('#fff')
  })

  it('uses the course name for the subtitle in the nav bar', () => {
    let tree = shallow(<DiscussionsList {...props} />)
    expect(tree.find('Screen').prop('subtitle')).toEqual(props.courseName)
  })

  it('shows the empty list when no discussions', () => {
    let tree = shallow(<DiscussionsList {...props} />)
    let emptyComponent = shallow(tree.find('SectionList').prop('ListEmptyComponent'))
    expect(emptyComponent.exists()).toEqual(true)
  })

  it('sets screen display mode when trait collection changes', () => {
    let horizontal = 'wide'
    props.navigator.traitCollection = jest.fn((cb) => {
      cb({
        window: { horizontal },
      })
    })
    let tree = shallow(<DiscussionsList {...props} />)
    expect(tree.state().isRegularScreenDisplayMode).toEqual(false)

    let screen = tree.find('Screen')
    horizontal = 'regular'
    screen.simulate('traitCollectionChange')
    expect(tree.state().isRegularScreenDisplayMode).toEqual(true)
  })

  it('applies the data correctly', () => {
    let discussions = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
      template.discussion({ id: '3', assignment: null }),
      template.discussion({ id: '4', assignment: null }),
      template.discussion({ id: '5', pinned: true }),
      template.discussion({ id: '6', locked: true }),
      template.discussion({ id: '7', locked: true, pinned: true }),
    ]
    let tree = shallow(<DiscussionsList {...props} discussions={discussions} />)
    expect(tree.find('SectionList').prop('sections')).toEqual([
      {
        key: 'C_pinned',
        data: [discussions[4], discussions[6]],
      },
      {
        key: 'B_discussion',
        data: discussions.slice(0, 4),
      },
      {
        key: 'A_locked',
        data: [discussions[5]],
      },
    ])
  })

  it('renders in correct order', () => {
    let discussions = [
      template.discussion({ id: '1', title: 'First', last_reply_at: '2117-03-28T15:07:56.312Z' }),
      template.discussion({ id: '2', title: 'Second', last_reply_at: '2118-03-28T15:07:56.312Z' }),
    ]
    let tree = shallow(<DiscussionsList {...props} discussions={discussions} />)
    let data = tree.find('SectionList').prop('sections')
    expect(data[0].data.map(({ title }) => title)).toEqual(['Second', 'First'])
  })

  it('does not show the create button when the user does not have permission', () => {
    props.permissions.create_discussion_topic = false
    let tree = shallow(<DiscussionsList {...props} />)
    expect(tree.find('Screen').prop('rightBarButtons')).toEqual(false)
  })

  it('navigates to discussion creation', () => {
    props.navigator.show = jest.fn()
    props.contextID = '1'
    let tree = shallow(<DiscussionsList {...props} />)
    const addBtn = tree.find('Screen').prop('rightBarButtons')[0]
    expect(addBtn).not.toBeUndefined()
    addBtn.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/new', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  it('navigates to a discussion on row press', () => {
    const discussion = template.discussion({ id: '1' })
    let row = shallow(
      new DiscussionsList({
        ...props,
        discussions: [discussion],
      }).renderRow({ item: discussion, index: 0 })
    ).find('Row')
    row.simulate('press')
    expect(props.navigator.show).toHaveBeenCalledWith(discussion.html_url)
  })

  it('returns correct options when pinned and locked', () => {
    props.discussions = []
    let list = shallow(<DiscussionsList {...props} />).instance()
    let options = list._optionsForTogglingDiscussion(template.discussion({ id: '2', pinned: true, locked: true }))
    let expected = ['Unpin', 'Open for comments', 'Delete', 'Cancel']
    expect(options).toEqual(expected)
  })

  it('returns correct options when unpinned and unlocked', () => {
    props.discussions = []
    let list = shallow(<DiscussionsList {...props} />).instance()
    let options = list._optionsForTogglingDiscussion(template.discussion({ id: '2', pinned: false, locked: false }))
    let expected = ['Pin', 'Close for comments', 'Delete', 'Cancel']
    expect(options).toEqual(expected)
  })

  it('Will open an action sheet and press pin/unpin', () => {
    const input = template.discussion({ pinned: false, locked: false })
    const expected = { id: input.id, pinned: true, locked: false }
    testActionSheet(input, expected, 0)
  })

  it('Will open an action sheet and press open/close for comments', () => {
    const input = template.discussion({ pinned: false, locked: false })
    const expected = { id: input.id, pinned: false, locked: true }
    testActionSheet(input, expected, 1)
  })

  it('Will open an action sheet and press open/close for comments when pinned', () => {
    const input = template.discussion({ pinned: true, locked: false })
    const expected = { id: input.id, pinned: false, locked: true }
    testActionSheet(input, expected, 1)
  })

  it('Will open an action sheet and press pinned when closed for comments', () => {
    const input = template.discussion({ pinned: false, locked: true })
    const expected = { id: input.id, pinned: true, locked: false }
    testActionSheet(input, expected, 0)
  })

  it('Will open an action sheet and press delete', () => {
    const input = template.discussion({ pinned: false, locked: true })
    const expected = template.discussion({ pinned: true, locked: false })
    testActionSheet(input, expected, 2, false)
  })

  it('Will open an action sheet and press cancel', () => {
    const input = template.discussion({ pinned: false, locked: true })
    const expected = template.discussion({ pinned: true, locked: false })
    testActionSheet(input, expected, 3, false)
  })

  it('confirms discussion deletion', () => {
    const input = template.discussion({ pinned: false, locked: true })
    let list = shallow(<DiscussionsList {...props} />).instance()
    list._confirmDeleteDiscussion = jest.fn()
    list._onToggleDiscussionGrouping(input)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](2)
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(list._confirmDeleteDiscussion).toHaveBeenCalledWith(input)
  })

  it('deletes a discussion', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1' })
    props.discussions = [one]
    props.deleteDiscussion = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.contextID = '1'
    let tree = shallow(new DiscussionsList({ ...props }).renderRow({ item: one, index: 0 }))
    const kabob = tree.find(`[testID="discussion.kabob-${props.discussions[0].id}"]`)
    kabob.simulate('press')
    expect(props.deleteDiscussion).toHaveBeenCalledWith(props.context, props.contextID, '1')
  })

  function testActionSheet (inputDiscussion: Discussion, expectedDiscussion: Discussion, buttonIndex: number, expectToCallUpdateDiscussion: boolean = true) {
    let list = shallow(<DiscussionsList {...props} />).instance()
    list._onToggleDiscussionGrouping(inputDiscussion)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](buttonIndex)
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    if (expectToCallUpdateDiscussion) {
      expect(props.updateDiscussion).toHaveBeenCalledWith('courses', '1', expectedDiscussion)
    }
  }
})

describe('map state to prop', () => {
  it('maps state to props', () => {
    const discussions = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
    ]
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            color: '#fff',
            course: {
              name: 'Foo',
            },
            discussions: {
              pending: 0,
              error: null,
              refs: ['1', '2'],
            },
          },
        },
        discussions: {
          '1': {
            data: discussions[0],
          },
          '2': {
            data: discussions[1],
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toMatchObject({
      discussions,
      courseColor: '#fff',
    })
  })

  it('maps state to props course discussions that have group children', () => {
    app.isStudent = jest.fn(() => true)
    const discussions = [
      template.discussion({ id: '1', group_category_id: '5', group_topic_children: [{ id: '3', group_id: '10' }] }),
      template.discussion({ id: '2', group_category_id: '5', group_topic_children: [{ id: '4', group_id: '11' }] }),
    ]
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            color: '#fff',
            course: {
              name: 'Foo',
            },
            discussions: {
              pending: 0,
              error: null,
              refs: ['1', '2'],
            },
          },
        },
        discussions: {
          '1': {
            data: discussions[0],
          },
          '2': {
            data: discussions[1],
          },
          '3': {
            data: template.discussion({ title: 'groupd discussion 3' }),
          },
          '4': {
            data: template.discussion({ title: 'groupd discussion 4' }),
          },
        },
        groups: {
          '10': { data: { name: 'A' } },
          '11': { data: { name: 'B' } },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1' })
    ).toMatchObject({
      discussions: [
        { ...discussions[0], html_url: '/groups/10/discussion_topics/3' },
        { ...discussions[1], html_url: '/groups/11/discussion_topics/4' },
      ],
      courseColor: '#fff',
    })
  })

  it('maps state to props group context', () => {
    const discussions = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
    ]
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        groups: {
          '1': {
            color: '#fff',
            group: { name: 'Foo' },
            discussions: {
              pending: 0,
              error: null,
              refs: ['1', '2'],
            },
          },
        },
        discussions: {
          '1': {
            data: discussions[0],
          },
          '2': {
            data: discussions[1],
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { context: 'groups', contextID: '1' }),
    ).toMatchObject({
      discussions,
      courseColor: '#fff',
    })
  })
})
