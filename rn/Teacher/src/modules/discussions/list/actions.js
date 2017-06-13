/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshDiscussions: createAction('discussionsList.refresh', (courseID: string) => {
    return {
      promise: api.getDiscussions(courseID),
      courseID,
    }
  }),
  updateDiscussion: createAction('discussion.edit.update', (updatedDiscussion: Discussion, originalDiscussion: Discussion, courseID: string) => {
    return {
      promise: api.updateDiscussion(courseID, updatedDiscussion),
      updatedDiscussion,
      originalDiscussion,
      handlesError: true,
    }
  }),
})

export default (Actions(canvas): any)
