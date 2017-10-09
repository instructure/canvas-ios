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
