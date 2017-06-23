// @flow

import inbox, { conversations } from '../reducer'
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

describe('deleteConversation', () => {
  it('handles deleting a conversation that resolves', async () => {
    const data = templates.conversation({ id: '2' })
    const api = {
      deleteConversation: apiResponse(data),
    }
    const action = InboxActions(api).deleteConversation('2')

    const defaultState = {
      '1': {
        pending: 0,
        error: null,
        data: templates.conversation({ id: '1' }),
      },
      '2': {
        pending: 0,
        error: null,
        data,
      },
    }
    const expectedPending = {
      ...defaultState,
      '2': {
        pending: 1,
        error: null,
        data,
      },
    }
    const expectedResolved = {
      '1': {
        pending: 0,
        error: null,
        data: templates.conversation({ id: '1' }),
      },
    }
    expect(await testAsyncReducer(conversations, action, defaultState)).toEqual([
      expectedPending,
      expectedResolved,
    ])
  })

  it('handles deleting a conversation that errors', async () => {
    const data = templates.conversation({ id: '2' })
    const api = {
      deleteConversation: apiError({ message: 'Something bad happened' }),
    }
    const action = InboxActions(api).deleteConversation('2')
    const defaultState = {
      '2': {
        pending: 0,
        error: null,
        data,
      },
    }
    const expectedPending = {
      '2': {
        pending: 1,
        error: null,
        data,
      },
    }
    const expectedRejected = {
      '2': {
        pending: 0,
        error: 'Something bad happened',
        data,
      },
    }
    expect(await testAsyncReducer(conversations, action, defaultState)).toEqual([
      expectedPending,
      expectedRejected,
    ])
  })
})
