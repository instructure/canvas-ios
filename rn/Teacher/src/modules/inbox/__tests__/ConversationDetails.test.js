/* @flow */
import 'react-native'
import React from 'react'
import { ConversationDetails, mapStateToProps, handleRefresh, shouldRefresh } from '../detail/ConversationDetails.js'
import { setSession } from '../../../api/session'

const template = {
  ...require('../../../api/canvas-api/__templates__/conversations'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../__templates__/helm'),
  ...require('../../../redux/__templates__/app-state'),
  ...require('../../../api/canvas-api/__templates__/session'),
}

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const navigator = template.navigator()
  const convo = template.conversation({
    id: '1',
  })

  const tree = renderer.create(
    <ConversationDetails conversation={convo} navigator={navigator} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with some messages', () => {
  const me = template.session()
  setSession(me)
  const navigator = template.navigator()
  const convo = template.conversation({
    id: '1',
    starred: true,
    subject: null,
    messages: [
      template.conversationMessage(),
    ],
  })

  const tree = renderer.create(
    <ConversationDetails conversation={convo} navigator={navigator} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('mapStateToProps', () => {
  const c1 = template.conversation({
    id: '1',
  })
  const appState = template.appState({
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
