//
// Copyright (C) 2017-present Instructure, Inc.
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

// @flow

import { shallow } from 'enzyme'
import * as React from 'react'
import {
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import * as template from '../../../../__templates__'
import {
  ConversationDetails,
  handleRefresh,
  mapStateToProps,
  shouldRefresh,
} from '../ConversationDetails'

jest
  .mock('AlertIOS', () => ({ alert: jest.fn() }))
  .mock('ActionSheetIOS', () => ({
    showActionSheetWithOptions: jest.fn(),
  }))

describe('ConversationDetails', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      conversation: template.conversation({ id: '1' }),
      conversationID: '1',
      messages: [],
      navigator: template.navigator(),
      enrollments: [template.enrollment()],
      refreshEnrollments: jest.fn(),
      refreshInboxAll: jest.fn(),
      refreshInboxUnread: jest.fn(),
      refreshInboxStarred: jest.fn(),
      refreshInboxSent: jest.fn(),
      refreshInboxArchived: jest.fn(),
      updateInboxSelectedScope: jest.fn(),
      refreshConversationDetails: jest.fn(),
      starConversation: jest.fn(),
      unstarConversation: jest.fn(),
      deleteConversation: jest.fn(),
      deleteConversationMessage: jest.fn(),
      markAsRead: jest.fn(),
    }
  })

  it('renders correctly', () => {
    const tree = shallow(<ConversationDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with no conversation', () => {
    props.conversation = null
    const tree = shallow(<ConversationDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with some messages', () => {
    props.messages = [template.conversationMessage()]
    const tree = shallow(<ConversationDetails {...props} />)
    expect(tree).toMatchSnapshot()
    expect(tree.find('FlatList').dive()).toMatchSnapshot()
  })

  it('renders with alternate data', () => {
    props.conversation = template.conversation({ id: '1', starred: true, subject: null })
    const tree = shallow(<ConversationDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('doesnt render messages that are pendingDelete', () => {
    props.messages = [template.conversationMessage({ pendingDelete: true })]
    const tree = shallow(<ConversationDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows options action sheet', () => {
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith(
      {
        options: [ 'Reply', 'Reply All', 'Forward', 'Delete', 'Cancel' ],
        destructiveButtonIndex: 3,
        cancelButtonIndex: 4,
      },
      expect.any(Function),
    )
  })

  it('replies only to author when Reply is chosen', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(0))
    const conversation = props.conversation = template.conversation({ audience: [ '1234', '6789' ] })
    props.conversationID = '1'
    props.messages = [
      template.conversationMessage({ id: '1', author_id: '1234' }),
    ]
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/conversations/1/add_message',
      { modal: true },
      {
        recipients: conversation.participants.slice(0, 1),
        contextName: conversation.context_name,
        contextCode: conversation.context_code,
        subject: conversation.subject,
        canSelectCourse: false,
        canEditSubject: false,
        navBarTitle: 'Reply',
      }
    )
  })

  it('replies to all when Reply is chosen on your own message', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(0))
    const conversation = props.conversation = template.conversation({ audience: [ '1234', '6789' ] })
    props.conversationID = '1'
    props.messages = [
      template.conversationMessage({ id: '1', author_id: '1' }),
    ]
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action('1')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/conversations/1/add_message',
      { modal: true },
      expect.objectContaining({
        recipients: conversation.participants,
      })
    )
  })

  it('replies to all when Reply All is chosen', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(1))
    const conversation = props.conversation = template.conversation({ audience: [ '1234', '6789' ] })
    props.conversationID = '1'
    props.messages = [
      template.conversationMessage({ id: '1', author_id: '1' }),
    ]
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/conversations/1/add_message',
      { modal: true },
      expect.objectContaining({
        recipients: conversation.participants,
      })
    )
  })

  it('calls deleteConversation from options', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.deleteConversation = jest.fn()
    props.conversationID = '1'
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.deleteConversation).toHaveBeenCalledWith('1')
  })

  it('should toggle starred', () => {
    props.conversation = template.conversation({ starred: false })
    const tree = shallow(<ConversationDetails {...props} />)
    shallow(tree.find('FlatList').prop('ListHeaderComponent'))
      .find('[testID="inbox.detail.not-starred"]').simulate('Press')
    expect(props.starConversation).toHaveBeenCalled()
    tree.setProps({ conversation: { ...props.conversation, starred: true } })
    shallow(tree.find('FlatList').prop('ListHeaderComponent'))
      .find('[testID="inbox.detail.starred"]').simulate('Press')
    expect(props.unstarConversation).toHaveBeenCalled()
  })

  it('passess all messages as included messages when forwarding the conversation', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(2))
    props.conversationID = '1'
    props.messages = [
      template.conversationMessage({ id: '1' }),
      template.conversationMessage({ id: '2' }),
    ]
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.show).toHaveBeenCalledWith('/conversations/1/add_message', { modal: true }, {
      contextName: props.conversation && props.conversation.context_name,
      contextCode: props.conversation && props.conversation.context_code,
      subject: `Fw: ${props.conversation && props.conversation.subject || ''}`,
      showCourseSelect: false,
      canEditSubject: false,
      navBarTitle: 'Forward',
      requireMessageBody: false,
      includedMessages: props.messages,
    })
  })

  it('only passes one message when forwarding a single message', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(2))
    props.conversationID = '1'
    props.messages = [template.conversationMessage({ id: '3' })]
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action('3')
    expect(props.navigator.show).toHaveBeenCalledWith('/conversations/1/add_message', { modal: true }, {
      contextName: props.conversation && props.conversation.context_name,
      contextCode: props.conversation && props.conversation.context_code,
      subject: `Fw: ${props.conversation && props.conversation.subject || ''}`,
      showCourseSelect: false,
      canEditSubject: false,
      navBarTitle: 'Forward',
      requireMessageBody: false,
      includedMessages: [props.messages[0]],
    })
  })

  it('does not allow forwarding of messages with no context_code', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(2))
    props.conversationID = '1'
    props.messages = [template.conversationMessage({ id: '3' })]
    props.conversation = template.conversation({ id: '1', context_code: undefined })
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action('3')
    expect(AlertIOS.alert).toHaveBeenCalled()
    expect(props.navigator.show).not.toHaveBeenCalled()
  })

  it('calls options with an id', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.conversationID = '1'
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action('2')
    expect(props.deleteConversationMessage).toHaveBeenCalledWith('1', '2')
  })

  it('calls navigator.pop when there is no conversation', () => {
    const tree = shallow(<ConversationDetails {...props} />)
    tree.setProps({ conversation: undefined })
    expect(props.navigator.pop).toHaveBeenCalled()
  })

  it('calls navigator.dismiss when there is no conversation and is modal', () => {
    props.navigator.isModal = true
    const tree = shallow(<ConversationDetails {...props} />)
    tree.setProps({ conversation: undefined })
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls pop after delete finishes', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.deleteConversation = jest.fn(() => {
      tree.setProps({ pending: 1 })
      tree.setProps({ pending: 0, conversation: null })
    })
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.pop).toHaveBeenCalled()
  })

  it('calls dismiss after delete finishes if modal', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((config, callback) => callback(config.options.length - 2))
    props.navigator.isModal = true
    props.deleteConversation = jest.fn(() => {
      tree.setProps({ pending: 1 })
      tree.setProps({ pending: 0, conversation: null })
    })
    const tree = shallow(<ConversationDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls markAsRead on componentDidMount when the conversation has workflow state of unread', () => {
    const myProps = {
      ...props,
      conversation: template.conversation({ workflow_state: 'unread' }),
    }
    shallow(<ConversationDetails {...myProps} />)
    expect(props.markAsRead).toHaveBeenCalledWith('1')
  })

  it('does not call markAsRead on componentDidMount when the conversation has workflow state of archived', () => {
    const myProps = {
      ...props,
      conversation: template.conversation({ workflow_state: 'archived' }),
    }
    shallow(<ConversationDetails {...myProps} />)
    expect(props.markAsRead).not.toHaveBeenCalledWith('1')
  })

  describe('mapStateToProps', () => {
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

    it('maps correctly', () => {
      const results = mapStateToProps(appState, { conversationID: c1.id })
      expect(results).toMatchObject({
        conversation: c1,
      })
    })
  })

  describe('handleRefresh', () => {
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

    it('refreshes', () => {
      handleRefresh(props)
      expect(props.refreshConversationDetails).toHaveBeenCalledWith('1')
    })
  })

  describe('shouldRefresh', () => {
    it('should refresh', () => {
      const conversation = template.conversation({ messages: null })
      const props = {
        conversation,
        conversationID: conversation.id,
        messages: [],
      }

      expect(shouldRefresh(props)).toEqual(true)
    })
  })
})
