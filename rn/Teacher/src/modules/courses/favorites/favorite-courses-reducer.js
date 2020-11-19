//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import CourseListActions from '../actions'
import handleAsync from '../../../utils/handleAsync'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'
import App from '../../app'

let { refreshCourses } = CourseListActions

export let defaultState: FavoriteCoursesState = {
  courseRefs: [],
  pending: 0,
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
}, defaultState)
