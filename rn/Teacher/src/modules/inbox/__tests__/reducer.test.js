// @flow

import inbox from '../reducer'
import { InboxActions } from '../actions'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const { refreshInboxAll, updateInboxSelectedScope } = InboxActions()
const templates = {
  ...require('../../../api/canvas-api/__templates__/conversations'),
}

test('it handles the data', () => {
  const data = [
    templates.conversation({ id: '1' }),
    templates.conversation({ id: '2' }),
  ]

  const action = {
    type: refreshInboxAll.toString(),
    payload: { result: { data } },
  }

  expect(inbox({}, action)).toEqual({
    conversations: {
      '1': { data: data[0] },
      '2': { data: data[1] },
    },
    selectedScope: 'all',
    all: {
      refs: [data[0].id, data[1].id],
      pending: 0,
    },
    unread: {
      refs: [],
      pending: 0,
    },
    sent: {
      refs: [],
      pending: 0,
    },
    archived: {
      refs: [],
      pending: 0,
    },
    starred: {
      refs: [],
      pending: 0,
    },
  })
})

test('handles updating scope', () => {
  const action = {
    type: updateInboxSelectedScope.toString(),
    payload: 'unread',
  }
  const result = inbox('all', action)
  expect(result).toMatchObject({
    selectedScope: 'unread',
  })
})

test('handled updating a single conversation', async () => {
  const convo = templates.conversation({ id: '2' })
  let action = InboxActions({ getConversationDetails: apiResponse(convo) }).refreshConversationDetails(convo.id)
  let state = await testAsyncReducer(inbox, action)
  expect(state).toMatchObject([
    {
      conversations: {
        [convo.id.toString()]: {
          pending: 1,
          error: null,
        },
      },
    },
    {
      conversations: {
        [convo.id.toString()]: {
          pending: 0,
          data: convo,
          error: null,
        },
      },
    },
  ])
})

test('handled updating a single conversation that errors', async () => {
  const convo = templates.conversation({ id: '2' })
  let action = InboxActions({ getConversationDetails: apiError({ message: 'error' }) }).refreshConversationDetails(convo.id)
  let state = await testAsyncReducer(inbox, action)
  expect(state).toMatchObject([
    {
      conversations: {
        [convo.id.toString()]: {
          pending: 1,
          error: null,
        },
      },
    },
    {
      conversations: {
        [convo.id.toString()]: {
          pending: 0,
          error: 'An error occured while fetching this conversation.',
        },
      },
    },
  ])
})
