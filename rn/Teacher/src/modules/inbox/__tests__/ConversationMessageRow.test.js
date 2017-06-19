/* @flow */
import 'react-native'
import React from 'react'
import ConversationMessage from '../components/ConversationMessageRow'
import { setSession } from '../../../api/session'

const template = {
  ...require('../../../api/canvas-api/__templates__/conversations'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../__templates__/helm'),
  ...require('../../../api/canvas-api/__templates__/session'),
}

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const session = template.session()
  setSession(session)
  const convo = template.conversation({
    id: '1',
  })
  const message = template.conversationMessage()

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with author being the logged in user', () => {
  const session = template.session()
  setSession(session)
  const convo = template.conversation({
    id: '1',
    participants: [
      { id: session.user.id, name: 'hey there i am bob' },
      { id: '99999999', name: 'hey there i am jane' },
    ],
    audience: ['99999999'],
  })
  const message = template.conversationMessage({
    author_id: session.user.id,
  })

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with author lots of participants', () => {
  const session = template.session()
  setSession(session)
  const convo = template.conversation({
    id: '1',
    participants: [
      { id: session.user.id, name: 'hey there i am bob' },
      { id: '1', name: 'hey there i am jane' },
      { id: '2', name: 'hey there i am joe' },
      { id: '3', name: 'hey there i am jim' },
    ],
    audience: ['1', '2', '3'],
  })
  const message = template.conversationMessage({
    author_id: session.user.id,
  })

  const tree = renderer.create(
    <ConversationMessage conversation={convo} message={message} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
