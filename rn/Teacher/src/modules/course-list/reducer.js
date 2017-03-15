// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from './actions'
import FavoritesActions from '../favorites-list/actions'
import type { CoursesState } from './props'
import handleAsync from '../../utils/handleAsync'
import i18n from 'format-message'
import groupCustomColors from '../../api/utils/group-custom-colors'
import localeSort from '../../utils/locale-sort'

export let defaultState: { courses: Course[], pending: number } = { courses: [], pending: 0 }

let { refreshCourses } = CourseListActions
let { toggleFavorite } = FavoritesActions

function toggleCourseFavorite (courses: Array<Course>, courseId: string): Array<Course> {
  let courseIndex = courses.findIndex(course => course.id.toString() === courseId)
  courses[courseIndex] = {
    ...courses[courseIndex],
    is_favorite: !courses[courseIndex].is_favorite,
  }
  return courses
}

const reducer: Reducer<CoursesState, any> = handleActions({
  [refreshCourses.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, [coursesResponse, colorsResponse]) => {
      const colors = groupCustomColors(colorsResponse.data).custom_colors.course
      return {
        ...state,
        courses: state.courses.concat(coursesResponse.data).sort((c1, c2) => localeSort(c1.name, c2.name)),
        customColors: colors,
        pending: state.pending - 1,
      }
    },
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

  [toggleFavorite.toString()]: handleAsync({
    pending: (state, { courseId }) => {
      return {
        ...state,
        pending: state.pending + 1,
        courses: toggleCourseFavorite(state.courses.slice(), courseId),
      }
    },
    resolved: (state) => ({ ...state, pending: state.pending - 1 }),
    rejected: (state, { courseId, error }) => {
      let errorMessage = i18n('Failed to toggle favorite')
      if (error.data.errors && error.data.errors.length > 0) {
        errorMessage = error.data.errors[0].message
      }
      return {
        ...state,
        error: errorMessage,
        pending: state.pending - 1,
        courses: toggleCourseFavorite(state.courses.slice(), courseId),
      }
    },
  }),
}, defaultState)

export type { CoursesState }

export default reducer
