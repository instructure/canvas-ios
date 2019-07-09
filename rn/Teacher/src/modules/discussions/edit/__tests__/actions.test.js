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
}

describe('createDiscussion', () => {
  it('should create discussion', async () => {
    const params = template.createDiscussionParams()
    const discussion = template.discussion(params)
    const api = {
      createDiscussion: apiResponse(discussion),
    }
    const context = 'courses'
    const contextID = '21'
    const actions = Actions(api)
    const action = actions.createDiscussion(context, contextID, params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.createDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          contextID,
          context,
        },
      },
      {
        type: actions.createDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params,
          handlesError: true,
          contextID,
          context,
        },
      },
    ])
  })
})

describe('updateDiscussion', () => {
  it('handles resolved', async () => {
    const params = template.updateDiscussionParams()
    const discussion = template.discussion(params)
    const api = {
      updateDiscussion: apiResponse(discussion),
    }
    const context = 'courses'
    const contextID = '21'
    const actions = Actions(api)
    const action = actions.updateDiscussion(context, contextID, params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.updateDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          context,
          contextID,
        },
      },
      {
        type: actions.updateDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params,
          handlesError: true,
          context,
          contextID,
        },
      },
    ])
  })

  it('handles rejected', async () => {
    const params = template.updateDiscussionParams()
    const api = {
      updateDiscussion: apiError({ message: 'Invalid token.', status: 500 }),
    }
    const context = 'courses'
    const contextID = '21'
    const actions = Actions(api)
    const action = actions.updateDiscussion(context, contextID, params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.updateDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          context,
          contextID,
        },
      },
      {
        type: actions.updateDiscussion.toString(),
        payload: {
          error: { data: { errors: [{ message: 'Invalid token.' }] } },
          params,
          handlesError: true,
          context,
          contextID,
        },
      },
    ])
  })
})

describe('delete discussion', () => {
  it('should delete the discussion', async () => {
    const discussion = template.discussion()
    const api = {
      deleteDiscussion: apiResponse(discussion),
    }
    const context = 'courses'
    const contextID = '21'
    const actions = Actions(api)
    const action = actions.deleteDiscussion(context, contextID, '43')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.deleteDiscussion.toString(),
        pending: true,
        payload: {
          discussionID: '43',
          context,
          contextID,
        },
      },
      {
        type: actions.deleteDiscussion.toString(),
        payload: {
          result: { data: discussion },
          discussionID: '43',
          context,
          contextID,
        },
      },
    ])
  })
})

describe('subscribeDiscussion', () => {
  it('should subscribe', async () => {
    const api = {
      subscribeDiscussion: apiResponse({}, { status: 204 }),
    }
    const context = 'courses'
    const contextID = '21'
    const actions = Actions(api)
    const action = actions.subscribeDiscussion(context, contextID, '2', true)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.subscribeDiscussion.toString(),
        pending: true,
        payload: {
          discussionID: '2',
          context,
          contextID,
          subscribed: true,
        },
      },
      {
        type: actions.subscribeDiscussion.toString(),
        payload: {
          result: { data: {} },
          discussionID: '2',
          context,
          contextID,
          subscribed: true,
        },
      },
    ])
  })
})

test('deletePendingNewDiscussion', () => {
  const context = 'courses'
  const contextID = '43'
  const actions = Actions({})
  const action = actions.deletePendingNewDiscussion(context, contextID)
  expect(action).toEqual({
    type: actions.deletePendingNewDiscussion.toString(),
    payload: {
      context, contextID,
    },
  })
})
