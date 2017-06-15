/* @flow */

import { Actions } from './../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
}

describe('refreshDiscussions', () => {
  it('should get discussions', async () => {
    const discussion = template.discussion({ title: 'refreshed' })
    const api = {
      getDiscussions: apiResponse([discussion]),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussions()
    const result = await testAsyncAction(action)
    expect(result).toMatchObject([
      {
        type: actions.refreshDiscussions.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussions.toString(),
        payload: {
          result: { data: [discussion] },
        },
      },
    ])
  })
})
