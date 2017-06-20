/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshDiscussionEntries: createAction('discussionDetailEntries.refresh', (courseID: string, discussionID: string) => {
    return {
      promise: Promise.all([
        api.getAllDiscussionEntries(courseID, discussionID),
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
})

export default (Actions(canvas): any)
