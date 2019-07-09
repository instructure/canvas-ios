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
