/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
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
