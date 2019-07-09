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

/* @flow */

import { Actions } from '../actions'
import { apiResponse, apiError } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../__templates__/discussion'),
  ...require('../../../../__templates__/assignments'),
}

describe('discussion detail tests', () => {
  it('should refresh discussion entries', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const discussionView = template.discussionView({ view: [] })
    const discussion = template.discussion({ assignment_id: '42' })
    const assignment = template.assignment({ id: '42' })

    const api = {
      getAllDiscussionEntries: apiResponse(discussionView),
      getDiscussion: apiResponse(discussion),
      getAssignment: apiResponse(assignment),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussionEntries(context, contextID, discussionID, false)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.refreshDiscussionEntries.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussionEntries.toString(),
        payload: {
          result: [{ data: discussionView }, { data: discussion }, { data: assignment }],
          context,
          contextID,
          discussionID: discussionID,
        },
      },
    ])
  })

  it('should refresh discussion entries with group context and assignment', async () => {
    const context = 'groups'
    const contextID = '1'
    const discussionID = '2'
    const discussionView = template.discussionView({ view: [] })
    const discussion = template.discussion({ assignment_id: '42' })
    const assignment = template.assignment({ id: '42' })

    const api = {
      getAllDiscussionEntries: apiResponse(discussionView),
      getDiscussion: apiResponse(discussion),
      getAssignment: apiResponse(assignment),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussionEntries(context, contextID, discussionID, false)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.refreshDiscussionEntries.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussionEntries.toString(),
        payload: {
          result: [{ data: discussionView }, { data: discussion }],
          context,
          contextID,
          discussionID: discussionID,
        },
      },
    ])
  })

  it('should refresh non-assignment discussion entries', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const discussionView = template.discussionView({ view: [] })
    const discussion = template.discussion({ assignment_id: null })

    const api = {
      getAllDiscussionEntries: apiResponse(discussionView),
      getDiscussion: apiResponse(discussion),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussionEntries(context, contextID, discussionID)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.refreshDiscussionEntries.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussionEntries.toString(),
        payload: {
          result: [{ data: discussionView }, { data: discussion }],
          context,
          contextID,
          discussionID: discussionID,
        },
      },
    ])
  })
})

describe('discussion edit reply tests', () => {
  it('should post a new reply', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const entryID = '3'
    const discussionReply = template.discussionReply()
    const lastReplyAt = (new Date()).toISOString()

    const api = {
      createEntry: apiResponse(discussionReply),
    }
    const actions = Actions(api)
    const action = actions.createEntry(context, contextID, discussionID, entryID, { messsage: discussionReply.message }, [], lastReplyAt)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.createEntry.toString(),
        pending: true,
      },
      {
        type: actions.createEntry.toString(),
        payload: {
          result: { data: template.discussionReply() },
          context,
          contextID,
          discussionID,
          entryID,
          indexPath: [],
          lastReplyAt,
        },
      },
    ])
  })

  it('should edit an existing reply', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const discussionReply = template.discussionEditReply()
    const entryID = discussionReply.id
    const newMessage = 'this is the new message'
    const expectedData = {
      ...discussionReply,
      message: newMessage,
    }
    const api = {
      editEntry: apiResponse(expectedData),
    }
    const actions = Actions(api)
    const action = actions.editEntry(context, contextID, discussionID, entryID, { messsage: newMessage })
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.editEntry.toString(),
        pending: true,
      },
      {
        type: actions.editEntry.toString(),
        payload: {
          result: { data: expectedData },
          context,
          contextID,
          discussionID: discussionID,
          entryID: entryID,
        },
      },
    ])
  })

  it('should delete discussion entry', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const entryID = '3'

    const api = {
      deleteDiscussionEntry: apiResponse({}),
    }
    const actions = Actions(api)
    const action = actions.deleteDiscussionEntry(context, contextID, discussionID, entryID)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.deleteDiscussionEntry.toString(),
        pending: true,
      },
      {
        type: actions.deleteDiscussionEntry.toString(),
        payload: {
          result: { data: {} },
          context,
          contextID,
          discussionID,
          entryID,
        },
      },
    ])
  })
})

describe('markAllAsRead', () => {
  it('has the correct data', async () => {
    const api = {
      markAllAsRead: apiError({ message: 'error' }),
    }
    const actions = Actions(api)
    const action = actions.markAllAsRead('courses', '1', '2', 3)
    const result = await testAsyncAction(action)

    expect(result).toMatchObject([
      {
        type: actions.markAllAsRead.toString(),
        pending: true,
        payload: {
          discussionID: '2',
          oldUnreadCount: 3,
        },
      },
      {
        type: actions.markAllAsRead.toString(),
        error: true,
        payload: {
          discussionID: '2',
          oldUnreadCount: 3,
        },
      },
    ])
  })
})

describe('markEntryAsRead', () => {
  it('has the correct data', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const entryID = '3'
    const api = {
      markEntryAsRead: apiError({ message: 'error' }),
    }
    const actions = Actions(api)
    const action = actions.markEntryAsRead(context, contextID, discussionID, entryID)
    const result = await testAsyncAction(action)

    expect(result).toMatchObject([
      {
        type: actions.markEntryAsRead.toString(),
        pending: true,
        payload: {
          discussionID: '2',
        },
      },
      {
        type: actions.markEntryAsRead.toString(),
        error: true,
        payload: {
          discussionID: '2',
        },
      },
    ])
  })
})

describe('refreshSingleDiscussion', () => {
  it('gets the correct data', async () => {
    const context = 'courses'
    const contextID = '1'
    const discussionID = '2'
    const discussion = template.discussion()

    const api = {
      getDiscussion: apiResponse(discussion),
    }
    const actions = Actions(api)
    const action = actions.refreshSingleDiscussion(context, contextID, discussionID)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.refreshSingleDiscussion.toString(),
        pending: true,
      }, {
        type: actions.refreshSingleDiscussion.toString(),
        payload: {
          result: { data: discussion },
          discussionID: discussionID,
        },
      }],
    )
  })
})

test('deletePendingReplies', () => {
  const actions = Actions({})
  const action = actions.deletePendingReplies('43')
  expect(action).toEqual({
    type: actions.deletePendingReplies.toString(),
    payload: {
      discussionID: '43',
    },
  })
})

test('it rates an entry', async () => {
  let context = 'courses'
  let contextID = '1'
  let discussionID = '2'
  let entryID = '3'
  let rating = 1

  let api = { rateEntry: apiResponse(null, { status: 204 }) }
  let actions = Actions(api)
  let action = actions.rateEntry('courses', '1', '2', '3', 1)

  let results = await testAsyncAction(action)
  expect(results).toMatchObject([{
    type: actions.rateEntry.toString(),
    pending: true,
  }, {
    type: actions.rateEntry.toString(),
    payload: {
      context,
      contextID,
      discussionID,
      entryID,
      rating,
    },
  }])
})
