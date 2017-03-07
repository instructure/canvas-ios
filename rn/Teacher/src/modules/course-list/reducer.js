// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from './actions'
import type { CoursesState } from './props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'

export let defaultState: { courses: Course[], pending: number } = { courses: [], pending: 0 }

let { refreshCourses } = CourseListActions

const reducer: Reducer<CoursesState, any> = handleActions({
  [refreshCourses.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, response) => ({
      ...state,
      courses: state.courses.concat(response.data),
      pending: state.pending - 1,
    }),
    rejected: (state, response) => {
      let errorMessage = i18n('No Courses Available')
      if (response.data.errors && response.data.errors.length > 0) {
        errorMessage = response.data.errors[0].message
      }
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
      }
    },
  }),
}, defaultState)

export default reducer
