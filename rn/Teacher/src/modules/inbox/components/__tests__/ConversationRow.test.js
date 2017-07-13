/* @flow */
import 'react-native'
import React from 'react'
import ConversationRow from '../ConversationRow'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const template = {
  ...require('../../../../api/canvas-api/__templates__/conversations'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

it('renders correctly', () => {
  const conversation = template.conversation()
  const tree = renderer.create(
    <ConversationRow conversation={conversation} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with different data', () => {
  const conversation = template.conversation({
    participants: null,
    subject: null,
    workflow_state: 'unread',
    starred: true,
  })
  const tree = renderer.create(
    <ConversationRow conversation={conversation} drawsTopLine={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with a bunch of people in there', () => {
  const conversation = template.conversation()
  conversation.participants = Array(100).fill().map((e, i) => ({ id: i.toString(), name: i.toString() }))
  const tree = renderer.create(
    <ConversationRow conversation={conversation} drawsTopLine={true} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('handles on press', () => {
  const conversation = template.conversation()
  const callback = jest.fn()
  const tree = renderer.create(
    <ConversationRow conversation={conversation} onPress={callback}/>
  ).toJSON()
  const button = explore(tree).selectByID(`inbox.conversation-${conversation.id}`) || {}
  button.props.onPress()
  expect(callback).toHaveBeenCalledWith(conversation.id)
})
