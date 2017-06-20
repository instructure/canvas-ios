/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import { type CreateEntryParameters } from '../../../api/canvas-api/discussions'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshDiscussionEntries: createAction('discussionDetailEntries.refresh', (courseID: string, discussionID: string, includeNewEntries: boolean) => {
    return {
      promise: Promise.all([
        api.getAllDiscussionEntries(courseID, discussionID, includeNewEntries),
        api.getDiscussion(courseID, discussionID),
      ]).then(([view, discussion]) => {
        if (discussion.data.assignment_id) {
          return Promise.all([
            Promise.resolve(view),
            Promise.resolve(discussion),
            api.getAssignment(courseID, discussion.data.assignment_id),
          ])
        }
        return Promise.resolve([view, discussion])
      }),
      courseID,
      discussionID,
    }
  }),
  createEntry: createAction('discussions.details.createEntry', (courseID: string, discussionID: string, parameters: CreateEntryParameters) => {
    return {
      promise: api.createEntry(courseID, discussionID, parameters),
      courseID,
      discussionID,
    }
  }),
  deleteDiscussionEntry: createAction('discussionDetail.delete-entry', (courseID: string, discussionID: string, entryID: string) => {
    return {
      promise: api.deleteDiscussionEntry(courseID, discussionID, entryID),
      courseID,
      discussionID,
      entryID,
    }
  }),
})

export default (Actions(canvas): any)
