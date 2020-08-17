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

import { FavoritesActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse, apiError } from '../../../../../test/helpers/apiMock'
import * as courseTemplate from '../../../../__templates__/course'

describe('edit favorite actions', () => {
  beforeEach(() => {
    console.warn = jest.fn()
  })

  test('toggleCourseFavorite workflow', async () => {
    const course = courseTemplate.course({ is_favorite: false })
    let actions = FavoritesActions({ favoriteCourse: apiResponse(1234) })
    let initialState = {
      courses: [course],
    }
    const result = await testAsyncAction(actions.toggleCourseFavorite(course.id, true), initialState)

    expect(result).toMatchObject([
      {
        type: actions.toggleCourseFavorite.toString(),
        payload: {
          courseID: course.id,
        },
        pending: true,
      },
      {
        type: actions.toggleCourseFavorite.toString(),
      },
    ])
  })

  test('toggleCourseFavorite workflow error', async () => {
    const course = courseTemplate.course({ is_favorite: false })
    let actions = FavoritesActions({ favoriteCourse: apiError() })
    let initialState = {
      courses: [course],
    }
    const result = await testAsyncAction(actions.toggleCourseFavorite(course.id, true), initialState)

    expect(console.warn).toHaveBeenCalled()
    expect(result).toMatchObject([
      {
        type: actions.toggleCourseFavorite.toString(),
        payload: {
          courseID: course.id,
        },
        pending: true,
      },
      {
        type: actions.toggleCourseFavorite.toString(),
        error: true,
        payload: {
          courseID: course.id,
        },
      },
    ])
  })
})
