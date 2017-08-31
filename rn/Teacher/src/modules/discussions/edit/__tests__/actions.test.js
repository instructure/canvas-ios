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
    const actions = Actions(api)
    const action = actions.createDiscussion('21', params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.createDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          courseID: '21',
        },
      },
      {
        type: actions.createDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params,
          handlesError: true,
          courseID: '21',
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
    const actions = Actions(api)
    const action = actions.updateDiscussion('21', params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.updateDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          courseID: '21',
        },
      },
      {
        type: actions.updateDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params,
          handlesError: true,
          courseID: '21',
        },
      },
    ])
  })

  it('handles rejected', async () => {
    const params = template.updateDiscussionParams()
    const api = {
      updateDiscussion: apiError({ message: 'Invalid token.', status: 500 }),
    }
    const actions = Actions(api)
    const action = actions.updateDiscussion('21', params)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.updateDiscussion.toString(),
        pending: true,
        payload: {
          params,
          handlesError: true,
          courseID: '21',
        },
      },
      {
        type: actions.updateDiscussion.toString(),
        payload: {
          error: { data: { errors: [{ message: 'Invalid token.' }] } },
          params,
          handlesError: true,
          courseID: '21',
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
    const actions = Actions(api)
    const action = actions.deleteDiscussion('21', '43')
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.deleteDiscussion.toString(),
        pending: true,
        payload: {
          discussionID: '43',
          courseID: '21',
        },
      },
      {
        type: actions.deleteDiscussion.toString(),
        payload: {
          result: { data: discussion },
          discussionID: '43',
          courseID: '21',
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
    const actions = Actions(api)
    const action = actions.subscribeDiscussion('1', '2', true)
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.subscribeDiscussion.toString(),
        pending: true,
        payload: {
          discussionID: '2',
          courseID: '1',
          subscribed: true,
        },
      },
      {
        type: actions.subscribeDiscussion.toString(),
        payload: {
          result: { data: {} },
          discussionID: '2',
          courseID: '1',
          subscribed: true,
        },
      },
    ])
  })
})

test('deletePendingNewDiscussion', () => {
  const actions = Actions({})
  const action = actions.deletePendingNewDiscussion('43')
  expect(action).toEqual({
    type: actions.deletePendingNewDiscussion.toString(),
    payload: {
      courseID: '43',
    },
  })
})
