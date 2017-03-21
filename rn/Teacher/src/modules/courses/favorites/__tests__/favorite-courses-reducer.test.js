// @flow

import { FavoritesActions } from '../../edit-favorites/actions'
import { favoriteCourses, defaultState } from '../favorite-courses-reducer'
import { apiResponse, apiError } from '../../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../../test/helpers/async'

test('toggleFavorite favorites a course', async () => {
  const courseID = '4123'
  const action = FavoritesActions({ favoriteCourse: apiResponse() }).toggleFavorite(courseID, true)
  const initialState = {
    ...defaultState,
    courseRefs: [],
  }
  const states = await testAsyncReducer(favoriteCourses, action, initialState)
  const courseRefs = [courseID]
  expect(states).toEqual([
    { pending: 1, courseRefs },
    { pending: 0, courseRefs },
  ])
})

test('toggleFavorite unfavorites a course', async () => {
  const courseID = '3322'
  const action = FavoritesActions({ unfavoriteCourse: apiResponse() }).toggleFavorite(courseID, false)
  const initialState = {
    ...defaultState,
    courseRefs: [courseID],
  }
  const states = await testAsyncReducer(favoriteCourses, action, initialState)
  const courseRefs = []
  expect(states).toEqual([
    { pending: 1, courseRefs },
    { pending: 0, courseRefs },
  ])
})

test('toggleFavorite reverts favorite on error', async () => {
  const courseID = '588'
  const action = FavoritesActions({ favoriteCourse: apiError({ message: 'error' }) }).toggleFavorite(courseID, true)
  const initialState: FavoriteCoursesState = {
    ...defaultState,
    courseRefs: [],
  }
  const state = await testAsyncReducer(favoriteCourses, action, initialState)
  expect(state).toEqual([
    { pending: 1, courseRefs: [courseID] },
    { pending: 0, courseRefs: [], error: 'error' },
  ])
})
