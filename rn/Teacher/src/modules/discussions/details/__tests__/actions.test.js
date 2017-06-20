/* @flow */

import { Actions } from '../actions'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
}

describe('discussion detail tests', () => {
  it('should refresh discussion entries', async () => {
    const courseID = '1'
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
          result: [{ data: discussionView }, { data: discussion }, { data: assignment }],
          courseID: courseID,
          discussionID: discussionID,
        },
      },
    ])
  })

  it('should refresh non-assignment discussion entries', async () => {
    const courseID = '1'
    const discussionID = '2'
    const discussionView = template.discussionView({ view: [] })
    const discussion = template.discussion({ assignment_id: null })

    const api = {
      getAllDiscussionEntries: apiResponse(discussionView),
      getDiscussion: apiResponse(discussion),
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
          result: [{ data: discussionView }, { data: discussion }],
          courseID: courseID,
          discussionID: discussionID,
        },
      },
    ])
  })
})
