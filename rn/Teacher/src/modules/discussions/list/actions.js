/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshDiscussions: createAction('discussionsList.refresh', (courseID: string) => {
    return {
      promise: api.getDiscussions(courseID),
      courseID,
    }
  }),
})

export default (Actions(canvas): *)
