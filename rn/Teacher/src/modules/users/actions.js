/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let UserProfileActions = (api: CanvasApi): * => ({
  refreshUsers: createAction('user-profiles.refresh', (userIDs: string[]) => {
    const promises = userIDs.map((userID) => {
      return api.getUserProfile(userID)
    })

    return {
      promise: Promise.all(promises),
      userIDs,
      handlesError: true,
    }
  }),
})

export default (UserProfileActions(canvas): *)
