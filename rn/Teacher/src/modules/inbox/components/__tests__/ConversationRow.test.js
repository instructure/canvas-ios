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
import 'react-native'
import React from 'react'
import ConversationRow from '../ConversationRow'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

const template = {
  ...require('../../../../__templates__/conversations'),
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

it('extract date', () => {
  const conversation = template.conversation({
    last_message_at: 'last_message_at',
    last_authored_message_at: 'last_authored_message_at',
  })
  expect(ConversationRow.extractDate(conversation)).toEqual(conversation.last_authored_message_at)
  conversation.last_authored_message_at = ''
  expect(ConversationRow.extractDate(conversation)).toEqual(conversation.last_message_at)
  conversation.last_authored_message_at = 'last_authored_message_at'
  conversation.properties = ['last_author']
  expect(ConversationRow.extractDate(conversation)).toEqual(conversation.last_authored_message_at)
  conversation.properties = []
  expect(ConversationRow.extractDate(conversation)).toEqual(conversation.last_message_at)
  conversation.last_message_at = ''
  expect(ConversationRow.extractDate(conversation)).toEqual(conversation.last_authored_message_at)
})
