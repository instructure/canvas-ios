//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from '../actions'
import FavoritesActions from '../edit-favorites/actions'
import handleAsync from '../../../utils/handleAsync'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'
import App from '../../app'

let { refreshCourses } = CourseListActions
let { toggleCourseFavorite } = FavoritesActions

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
    pending: (state) => {
      return { ...state, pending: state.pending + 1, error: undefined }
    },
    resolved: (state, { result: [coursesResponse] }) => {
      const favorites: EntityRefs = coursesResponse.data
        .filter(App.current().filterCourse)
        .filter((course) => course.is_favorite)
        .map((course) => course.id)

      return {
        ...state,
        courseRefs: favorites,
        pending: state.pending - 1,
        error: undefined,
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

  [toggleCourseFavorite.toString()]: handleAsync({
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
