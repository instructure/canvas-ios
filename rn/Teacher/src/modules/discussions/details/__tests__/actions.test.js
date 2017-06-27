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
    const action = actions.refreshDiscussionEntries(courseID, discussionID, false)
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

describe('discussion edit reply tests', () => {
  it('should post a new reply', async () => {
    const courseID = '1'
    const discussionID = '2'
    const discussionReply = template.discussionReply()

    const api = {
      createEntry: apiResponse(discussionReply),
    }
    const actions = Actions(api)
    const action = actions.createEntry(courseID, discussionID, { messsage: discussionReply.message })
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
          courseID: courseID,
          discussionID: discussionID,
        },
      },
    ])
  })

  it('should edit an existing reply', async () => {
    const courseID = '1'
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
    const action = actions.editEntry(courseID, discussionID, entryID, { messsage: newMessage })
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
          courseID: courseID,
          discussionID: discussionID,
          entryID: entryID,
        },
      },
    ])
  })

  it('should delete discussion entry', async () => {
    const courseID = '1'
    const discussionID = '2'
    const entryID = '3'

    const api = {
      deleteDiscussionEntry: apiResponse({}),
    }
    const actions = Actions(api)
    const action = actions.deleteDiscussionEntry(courseID, discussionID, entryID)
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
          courseID,
          discussionID,
          entryID,
        },
      },
    ])
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
