// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from '../actions'
import FavoritesActions from '../edit-favorites/actions'
import handleAsync from '../../../utils/handleAsync'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'

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
    resolved: (state, { result: [coursesResponse] }) => {
      const favorites: EntityRefs = coursesResponse.data
        .filter((course) => course.is_favorite)
        .map((course) => course.id)

      return {
        ...state,
        courseRefs: favorites,
        pending: state.pending - 1,
      }
    },
    rejected: (state, { error: response }) => {
      return {
        ...state,
        error: parseErrorMessage(response),
        pending: state.pending - 1,
      }
    },
  }),

  [toggleFavorite.toString()]: handleAsync({
    pending: (state, { courseID, markAsFavorite }) => toggleFavoriteCourse(state, courseID, markAsFavorite, +1),
    resolved: (state) => ({ ...state, pending: state.pending - 1 }),
    rejected: (state, { courseID, markAsFavorite, error }) => {
      return {
        ...toggleFavoriteCourse(state, courseID, !markAsFavorite, -1),
        error: parseErrorMessage(error),
      }
    },
  }),
}, defaultState)
