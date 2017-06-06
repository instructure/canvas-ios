// @flow

import { InboxActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'

const template = {
  ...require('../../../api/canvas-api/__templates__/conversations'),
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

test('update scope', async () => {
  const actions = InboxActions()
  const result = actions.updateInboxSelectedScope('unread')
  expect(result).toEqual({ 'payload': 'unread', 'type': 'inbox.update-scope' })
})
