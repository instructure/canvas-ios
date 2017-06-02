/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
}

describe('discussion detail tests', () => {
  it('should refresh discussion entries', async () => {
    const courseID = '1'
    const discussionID = '2'
    const discussionView = template.discussionView({ view: [] })

    const api = {
      getAllDiscussionEntries: apiResponse(discussionView),
    }
    const actions = Actions(api)
    const action = actions.refreshDiscussionEntries(courseID, discussionID)
    const state = await testAsyncAction(action)

    expect(state).toMatchObject([
      {
        type: actions.refreshDiscussionEntries.toString(),
        pending: true,
      },
      {
        type: actions.refreshDiscussionEntries.toString(),
        payload: {
          result: { data: discussionView },
          courseID: courseID,
          discussionID: discussionID,
        },
      },
    ])
  })
})
