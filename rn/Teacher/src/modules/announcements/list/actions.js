/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshAnnouncements: createAction('announcements.list.refresh', (courseID: string) => {
    return {
      promise: api.getDiscussions(courseID, { only_announcements: true }),
      courseID,
    }
  }),
})

export default (Actions(canvas): any)
