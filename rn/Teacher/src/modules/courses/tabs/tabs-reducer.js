/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseDetailsActions from './actions'
import handleAsync from '../../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: TabsState = { tabs: [], pending: 0 }

let { refreshTabs } = CourseDetailsActions
const availableCourseTabs = ['assignments']

export const tabs: Reducer<TabsState, any> = handleActions({
  [refreshTabs.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result }) => {
      const orderedTabs = result.data
        .filter((tab) => availableCourseTabs.includes(tab.id))
        .sort((t1, t2) => (t1.position - t2.position))
      return {
        ...state,
        tabs: orderedTabs,
        pending: state.pending - 1,
      }
    },
    rejected: (state, response) => {
      let errorMessage = i18n('Could not get course information')
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
      }
    },
  }),
}, defaultState)
