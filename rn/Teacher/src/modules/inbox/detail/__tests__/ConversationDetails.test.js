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
import {
  ActionSheetIOS,
} from 'react-native'
import React from 'react'
import { ConversationDetails, mapStateToProps, handleRefresh, shouldRefresh, type ConversationDetailsProps } from '../ConversationDetails.js'
import { setSession } from 'instructure-canvas-api'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

const template = {
  ...require('../../../../__templates__/conversations'),
  ...require('../../../../__templates__/users'),
  ...require('../../../../__templates__/enrollments'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/session'),
}

jest
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('../../../../routing/Screen')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const Screen = (props: ConversationDetailsProps) => {
  const screen = renderer.create(<ConversationDetails {...props} />)
  const tree = () => screen.toJSON()
  return {
    component: screen,
    get optionsButton (): any {
      return explore(tree()).selectRightBarButton('inbox.detail.options.button')
    },

    get instance (): any {
      return screen.getInstance()
    },

    tapOptionsButton () {
      this.optionsButton.action()
      return this
    },

    testRender () {
      expect(tree()).toMatchSnapshot()
    },
  }
}

describe('ConversationDetails', () => {
  let props
  beforeEach(() => {
    props = {
      conversation: template.conversation({ id: '1' }),
      conversationID: '1',
      messages: [],
      refreshConversationDetails: jest.fn(),
      refreshEnrollments: jest.fn(),
      starConversation: jest.fn(),
      unstarConversation: jest.fn(),
      deleteConversation: jest.fn(),
      markAsRead: jest.fn(),
      navigator: template.navigator(),
      enrollments: [template.enrollment()],
    }
  })

  beforeAll(() => {
    setSession(template.session())
  })

  it('renders correctly', () => {
    Screen(props).testRender()
  })

  it('renders correctly with some messages', () => {
    props.messages = [template.conversationMessage()]
    Screen(props).testRender()
  })

  it('renders with alternate data', () => {
    props.conversation = template.conversation({ id: '1', starred: true, subject: null })
    Screen(props).testRender()
  })

  it('shows options action sheet', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn()
    Screen(props).tapOptionsButton()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith(
      {
        options: ['Forward', 'Delete', 'Cancel'],
        destructiveButtonIndex: 1,
        cancelButtonIndex: 2,
      },
      expect.any(Function),
    )
  })

  it('calls deleteConversation from options', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.deleteConversation = jest.fn()
    props.conversationID = '1'
    Screen(props).tapOptionsButton()
    expect(props.deleteConversation).toHaveBeenCalledWith('1')
  })

  it('should toggle starred', () => {
    const conversation = template.conversation({
      starred: false,
    })
    const unstarConversation = jest.fn(() => {
      conversation.starred = false
    })
    const starConversation = jest.fn(() => {
      conversation.starred = true
    })

    const props = {
      conversation: undefined,
      unstarConversation,
      starConversation,
      markAsRead: jest.fn(),
    }

    let tree = renderer.create(
      <ConversationDetails {...props} />
    )
    let instance = tree.getInstance()
    instance._toggleStarred()

    props.conversation = conversation
    tree = renderer.create(
      <ConversationDetails {...props} />
    )
    instance = tree.getInstance()
    instance._toggleStarred()
    expect(starConversation).toHaveBeenCalled()
    instance._toggleStarred()
    expect(unstarConversation).toHaveBeenCalled()
  })

  it('it passess all messages as included messages when forwarding the conversation', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 3))
    props.conversationID = '1'
    props.messages = [
      template.conversationMessage({ id: '1' }),
      template.conversationMessage({ id: '2' }),
    ]
    Screen(props).tapOptionsButton()
    expect(props.navigator.show).toHaveBeenCalledWith('/conversations/1/add_message', { modal: true }, {
      contextName: props.conversation.context_name,
      contextCode: props.conversation.context_code,
      subject: `Fw: ${props.conversation.subject}`,
      showCourseSelect: false,
      canEditSubject: false,
      navBarTitle: 'Forward',
      requireMessageBody: false,
      includedMessages: props.messages,
    })
  })

  it('it only passes one message when forwarding a single message', () => {
    props.conversationID = '1'
    props.messages = [template.conversationMessage({ id: '3' })]
    Screen(props).instance.forwardMessage('3')
    expect(props.navigator.show).toHaveBeenCalledWith('/conversations/1/add_message', { modal: true }, {
      contextName: props.conversation.context_name,
      contextCode: props.conversation.context_code,
      subject: `Fw: ${props.conversation.subject}`,
      showCourseSelect: false,
      canEditSubject: false,
      navBarTitle: 'Forward',
      requireMessageBody: false,
      includedMessages: [props.messages[0]],
    })
  })

  it('calls options with an id', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.deleteConversation = jest.fn()
    props.conversationID = '1'
    Screen(props).instance.showOptionsActionSheet('2')
    expect(props.deleteConversation).toHaveBeenCalledWith('2')
  })

  it('calls pop after delete finishes', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.navigator.pop = jest.fn()
    const screen = Screen(props)
    props.deleteConversation = jest.fn(() => {
      setProps(screen.component, { pending: 1 })
      setProps(screen.component, { pending: 0, conversation: null })
    })
    screen.component.update(<ConversationDetails {...props} />)
    screen.tapOptionsButton()
    expect(props.navigator.pop).toHaveBeenCalled()
  })

  it('calls markAsRead on componentDidMount', () => {
    renderer.create(
      <ConversationDetails {...props} />
    )

    expect(props.markAsRead).toHaveBeenCalledWith('1')
  })
})

it('mapStateToProps', () => {
  const c1 = template.conversation({
    id: '1',
  })
  const appState = template.appState({
    entities: {
      courses: {
        '1': {
          enrollments: {
            refs: ['1'],
          },
        },
      },
      enrollments: {
        '1': template.enrollment(),
      },
    },
    inbox: {
      conversations: {
        '1': { data: c1 },
      },
      selectedScope: 'all',
      all: { refs: [c1.id] },
      unread: { refs: [] },
      starred: { refs: [] },
    },
  })

  const results = mapStateToProps(appState, { conversationID: c1.id })
  expect(results).toMatchObject({
    conversation: c1,
  })
})

it('handleRefresh', () => {
  const props = {
    refreshConversationDetails: jest.fn(),
    starConversation: jest.fn(),
    unstarConversation: jest.fn(),
    markAsRead: jest.fn(),
    conversationID: '1',
    conversation: null,
    messages: [],
    navigator: template.navigator(),
  }

  handleRefresh(props)
  expect(props.refreshConversationDetails).toHaveBeenCalledWith('1')
})

it('should refresh', () => {
  const conversation = template.conversation({ messages: null })
  const props = {
    conversation,
    conversationID: conversation.id,
    messages: [],
  }

  expect(shouldRefresh(props)).toEqual(true)
})
