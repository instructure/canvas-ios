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

// @flow

import { InboxActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

const template = {
  ...require('../../../__templates__/conversations'),
}

test('should refresh conversations', async () => {
  const conversations = [
    template.conversation({ id: '1' }),
    template.conversation({ id: '2' }),
  ]

  let actions = InboxActions({
    getConversations: apiResponse(conversations),
  })

  const keys = Object.keys(actions)
  keys.forEach(async (type) => {
    const actionType = type.toString()
    if (actionType === 'updateInboxSelectedScope') return
    const func = actions[actionType]
    let result = await testAsyncAction(func())
    expect(result).toMatchObject([
      {
        type: actionType,
        pending: true,
        payload: {},
      },
      {
        type: actionType,
        payload: {
          result: { data: conversations },
        },
      },
    ])
  })
})

test('should use next if it is provided', () => {
  const conversations = [
    template.conversation({ id: '1' }),
    template.conversation({ id: '2' }),
  ]

  let actions = InboxActions({
    getConversations: apiResponse(conversations),
  })

  const keys = Object.keys(actions)
  keys.forEach(async (type) => {
    let next = jest.fn()
    const actionType = type.toString()
    if (actionType === 'updateInboxSelectedScope') return
    const func = actions[actionType]
    let result = await testAsyncAction(func(next))
    expect(result).toMatchObject({
      payload: {
        usedNext: true,
      },
    })
    expect(next).toHaveBeenCalled()
  })
})

test('update scope', async () => {
  const actions = InboxActions()
  const result = actions.updateInboxSelectedScope('unread')
  expect(result).toEqual({ 'payload': 'unread', 'type': 'inbox.update-scope' })
})

test('deleteConversation', async () => {
  const data = template.conversation()
  const api = {
    deleteConversation: apiResponse(data),
  }
  const actions = InboxActions(api)
  const action = actions.deleteConversation('12')
  const result = await testAsyncAction(action)
  expect(result).toMatchObject([
    {
      type: actions.deleteConversation.toString(),
      pending: true,
      payload: {
        conversationID: '12',
      },
    },
    {
      type: actions.deleteConversation.toString(),
      payload: {
        result: { data },
        conversationID: '12',
      },
    },
  ])
  expect(api.deleteConversation).toHaveBeenCalledWith('12')
})

test('deleteConversationMessage', async () => {
  const api = {
    deleteConversationMessage: () => Promise.resolve(),
  }
  const actions = InboxActions(api)
  const action = actions.deleteConversationMessage('12', '13')
  const result = await testAsyncAction(action)
  expect(result).toMatchObject([
    {
      type: actions.deleteConversationMessage.toString(),
      pending: true,
      payload: {
        conversationID: '12',
        messageID: '13',
      },
    },
    {
      type: actions.deleteConversationMessage.toString(),
      payload: {
        conversationID: '12',
        messageID: '13',
      },
    },
  ])
})

test('markAsRead', async () => {
  let data = template.conversation()
  let api = {
    markConversationAsRead: apiResponse(data),
  }
  const actions = InboxActions(api)
  const action = actions.markAsRead('1')
  const result = await testAsyncAction(action)
  expect(result).toMatchObject([
    {
      type: actions.markAsRead.toString(),
      pending: true,
      payload: {
        conversationID: '1',
      },
    },
    {
      type: actions.markAsRead.toString(),
      payload: {
        result: { data },
        conversationID: '1',
      },
    },
  ])
})
