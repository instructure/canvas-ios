/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import { type CreateDiscussionParameters } from '../../../api/canvas-api/discussions'

export let Actions: (typeof canvas) => any = (api) => ({
  createDiscussion: createAction('discussions.edit.create', (courseID: string, params: CreateDiscussionParameters) => {
    return {
      promise: api.createDiscussion(courseID, params),
      params,
      handlesError: true,
      courseID,
    }
  }),
  deletePendingNewDiscussion: createAction('discussions.edit.deletePendingNew', (courseID: string) => ({
    courseID,
  })),
})

export default (Actions(canvas): any)
