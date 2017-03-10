/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseDetailsActions from './actions'
import type { TabsState } from './props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'
import groupCustomColors from '../../api/utils/group-custom-colors'

export let defaultState: { tabs: Tab[], pending: number, courseColors: {} } = { tabs: [], pending: 0, courseColors: {} }

let { refreshTabs } = CourseDetailsActions
const availableCourseTabs = ['assignments']

const reducer: Reducer<TabsState, any> = handleActions({
  [refreshTabs.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, [tabResponse, colorsResponse]) => {
      const colors = groupCustomColors(colorsResponse.data).custom_colors.course
      return {
        ...state,
        tabs: tabResponse.data.filter((tab) => availableCourseTabs.includes(tab.id)),
        courseColors: colors,
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

export default reducer
