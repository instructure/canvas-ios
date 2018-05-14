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

import React from 'react'
import { ActionSheetIOS, AlertIOS } from 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionsList, mapStateToProps, type Props } from '../DiscussionsList'
import explore from '@test/helpers/explore'
import app from '@modules/app'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing')
  .mock('ActionSheetIOS', () => ({
    showActionSheetWithOptions: jest.fn(),
  }))
  .mock('../../../../routing/Screen')
  .mock('../../../app', () => ({
    isTeacher: jest.fn(),
  }))

const template = {
  ...require('@templates/helm'),
  ...require('@templates/discussion'),
  ...require('@redux/__templates__/app-state'),
}

describe('DiscussionsList', () => {
  let props: Props
  beforeEach(() => {
    jest.resetAllMocks()
    app.isTeacher = jest.fn(() => true)
    props = {
      pending: false,
      refreshing: false,
      discussions: [],
      navigator: template.navigator(),
      courseColor: null,
      updateDiscussion: jest.fn(),
      refreshDiscussions: jest.fn(),
      deleteDiscussion: jest.fn(),
      context: 'courses',
      contextID: '1',
      permissions: template.discussionPermissions(),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders as student app', () => {
    props.permissions.create_discussion_topic = false
    app.isTeacher = jest.fn(() => false)
    testRender(props)
  })

  it('renders an activity indicator while loading', () => {
    testRender({
      ...props,
      pending: true,
    })
  })

  it('renders discussions', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1' })
    const two = template.discussion({ id: '2', title: 'discussion 2' })
    props.discussions = [one, two]
    testRender(props)
  })

  it('renders discussions with no assignments', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1', assignment: null })
    const two = template.discussion({ id: '2', title: 'discussion 2', assignment: null })
    props.discussions = [one, two]
    testRender(props)
  })

  it('renders pinned discussions', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1', pinned: true })
    const two = template.discussion({ id: '2', title: 'discussion 2', locked: true })
    const tre = template.discussion({ id: '3', title: 'discussion 3', locked: true, pinned: true })
    props.discussions = [one, two, tre]
    testRender(props)
  })

  it('navigates to discussion', () => {
    const discussion = template.discussion({ id: '1' })
    props.discussions = [discussion]
    const tree = render(props).toJSON()

    const row: any = explore(tree).selectByID('discussion-row-0')
    row.props.onPress()

    expect(props.navigator.show).toHaveBeenCalledWith(discussion.html_url)
  })

  it('renders in correct order', () => {
    props.discussions = [
      template.discussion({ id: '1', title: 'First', due_at: '2118-03-28T15:07:56.312Z' }),
      template.discussion({ id: '2', title: 'Second', due_at: '2117-03-28T15:07:56.312Z' }),
    ]
    testRender(props)
  })

  it('returns correct options when pinned and locked', () => {
    props.discussions = []
    let list = render(props).getInstance()
    let options = list._optionsForTogglingDiscussion(template.discussion({ id: '2', pinned: true, locked: true }))
    let expected = ['Unpin', 'Open for comments', 'Delete', 'Cancel']
    expect(options).toEqual(expected)
  })

  it('returns correct options when unpinned and unlocked', () => {
    props.discussions = []
    let list = render(props).getInstance()
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

  it('Will ask to confirm delete discussion', () => {
    const input = template.discussion({ pinned: false, locked: true })
    let list = render(props).getInstance()
    list._confirmDeleteDiscussion = jest.fn()
    list._onToggleDiscussionGrouping(input)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](2)
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(list._confirmDeleteDiscussion).toHaveBeenCalledWith(input)
  })

  it('deletes discussion onConfirmation', () => {
    const one = template.discussion({ id: '1', title: 'discussion 1' })
    props.discussions = [one]
    props.deleteDiscussion = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.contextID = '1'
    const kabob: any = explore(render(props).toJSON()).selectByID(`discussion.kabob-${props.discussions[0].id}`)
    kabob.props.onPress()
    expect(props.deleteDiscussion).toHaveBeenCalledWith(props.context, props.contextID, '1')
  })

  it('navigates to new discussion form', () => {
    props.navigator.show = jest.fn()
    props.contextID = '1'
    const addBtn: any = explore(render(props).toJSON()).selectRightBarButton('discussions.list.add.button')
    addBtn.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/new', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  function testActionSheet (inputDiscussion: Discussion, expectedDiscussion: Discussion, buttonIndex: number, expectToCallUpdateDiscussion: boolean = true) {
    let list = render(props).getInstance()
    list._onToggleDiscussionGrouping(inputDiscussion)
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][1](buttonIndex)
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    if (expectToCallUpdateDiscussion) {
      expect(props.updateDiscussion).toHaveBeenCalledWith('courses', '1', expectedDiscussion)
    }
  }

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<DiscussionsList {...props} />)
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
