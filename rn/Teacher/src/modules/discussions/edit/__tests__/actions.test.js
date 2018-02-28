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
