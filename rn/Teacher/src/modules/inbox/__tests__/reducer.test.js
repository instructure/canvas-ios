// @flow

import inbox from '../reducer'
import InboxActions from '../actions'

const { refreshInboxAll, updateInboxSelectedScope } = InboxActions
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
      '1': data[0],
      '2': data[1],
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
