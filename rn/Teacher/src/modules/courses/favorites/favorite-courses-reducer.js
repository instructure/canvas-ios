// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from '../actions'
import FavoritesActions from '../edit-favorites/actions'
import handleAsync from '../../../utils/handleAsync'
import i18n from 'format-message'

let { refreshCourses } = CourseListActions
let { toggleFavorite } = FavoritesActions

export let defaultState: FavoriteCoursesState = {
  courseRefs: [],
  pending: 0,
}

function toggleFavoriteCourse (
  state: FavoriteCoursesState = defaultState,
  courseID: string,
  markAsFavorite: boolean,
  netPending: number
): FavoriteCoursesState {
  const currentlyFavorite = state.courseRefs.includes(courseID)

  let courseRefs = state.courseRefs
  if (!currentlyFavorite && markAsFavorite) {
    courseRefs = [...state.courseRefs, courseID]
  } else if (currentlyFavorite && !markAsFavorite) {
    courseRefs = state.courseRefs.filter(favoriteCourseID => favoriteCourseID !== courseID)
  }

  return {
    ...state,
    pending: state.pending + netPending,
    courseRefs,
  }
}

export const favoriteCourses: Reducer<FavoriteCoursesState, any> = handleActions({
  [refreshCourses.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, [coursesResponse]) => {
      const favorites: EntityRefs = coursesResponse.data
        .filter((course) => course.is_favorite)
        .map((course) => course.id.toString())

      return {
        ...state,
        courseRefs: favorites,
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
    pending: (state, { courseID, markAsFavorite }) => toggleFavoriteCourse(state, courseID, markAsFavorite, +1),
    resolved: (state) => ({ ...state, pending: state.pending - 1 }),
    rejected: (state, { courseID, markAsFavorite, error }) => {
      let errorMessage = i18n('Failed to toggle favorite')
      if (error.data.errors && error.data.errors.length > 0) {
        errorMessage = error.data.errors[0].message
      }
      return {
        ...toggleFavoriteCourse(state, courseID, !markAsFavorite, -1),
        error: errorMessage,
      }
    },
  }),
}, defaultState)
