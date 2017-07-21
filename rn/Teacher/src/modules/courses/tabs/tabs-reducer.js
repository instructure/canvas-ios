/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import TabsActions from './actions'
import handleAsync from '../../../utils/handleAsync'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'

export let defaultState: TabsState = { tabs: [], pending: 0 }

let { refreshTabs } = TabsActions

export const tabs: Reducer<TabsState, any> = handleActions({
  [refreshTabs.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, { result }) => {
      const availableCourseTabs = ['assignments', 'quizzes', 'discussions', 'announcements']
      const orderedTabs = result.data
        .filter((tab) => availableCourseTabs.includes(tab.id))
        .sort((t1, t2) => (t1.position - t2.position))
      return {
        ...state,
        tabs: orderedTabs,
        pending: state.pending - 1,
      }
    },
    rejected: (state, { error }) => {
      return {
        ...state,
        error: parseErrorMessage(error),
        pending: state.pending - 1,
      }
    },
  }),
}, defaultState)
