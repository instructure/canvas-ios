// @flow

import { FavoritesActions } from '../actions'
import { defaultState } from '../../course-list/reducer'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

test('toggleFavorite workflow', async () => {
  const course = courseTemplate.course({ is_favorite: false })
  let actions = FavoritesActions({ favoriteCourse: apiResponse(1234) })
  let initialState = {
    ...defaultState,
    courses: [course],
  }
  const result = await testAsyncAction(actions.toggleFavorite(course.id, true), initialState)

  expect(result).toMatchObject([
    {
      type: actions.toggleFavorite.toString(),
      payload: {
        courseId: course.id,
      },
      pending: true,
    },
    {
      type: actions.toggleFavorite.toString(),
    },
  ])
})

test('toggleFavorite workflow error', async () => {
  const course = courseTemplate.course({ is_favorite: false })
  let actions = FavoritesActions({ favoriteCourse: apiError() })
  let initialState = {
    ...defaultState,
    courses: [course],
  }
  const result = await testAsyncAction(actions.toggleFavorite(course.id, true), initialState)

  expect(result).toMatchObject([
    {
      type: actions.toggleFavorite.toString(),
      payload: {
        courseId: course.id,
      },
      pending: true,
    },
    {
      type: actions.toggleFavorite.toString(),
      error: true,
      payload: {
        courseId: course.id,
      },
    },
  ])
})
