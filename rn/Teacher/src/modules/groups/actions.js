/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export let GroupActions: (typeof canvas) => any = (api) => ({
  refreshUserGroups: createAction('groups.refresh-all', () => {
    return {
      promise: api.getUserGroups(),
    }
  }),
})

export default (GroupActions(canvas): any)
