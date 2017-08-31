/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshAnnouncements: createAction('announcements.list.refresh', (courseID: string) => {
    return {
      promise: api.getDiscussions(courseID, { only_announcements: true }),
      courseID,
    }
  }),
})

export default (Actions(canvas): *)
