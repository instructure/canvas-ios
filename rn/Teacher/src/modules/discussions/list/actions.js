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
})

export default (Actions(canvas): any)
