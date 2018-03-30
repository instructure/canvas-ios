//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { FavoritesActions } from '../actions'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse, apiError } from '../../../../../test/helpers/apiMock'
import * as courseTemplate from '../../../../__templates__/course'

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
