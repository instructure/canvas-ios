/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshDiscussionEntries: createAction('discussionDetailEntries.refresh', (courseID: string, discussionID: string) => {
    return {
      promise: api.getAllDiscussionEntries(courseID, discussionID),
      courseID,
      discussionID,
    }
  }),
})

export default (Actions(canvas): any)
