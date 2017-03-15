// @flow

import { CoursesActions } from '../actions'
import { FavoritesActions } from '../../favorites-list/actions'
import coursesReducer, { defaultState } from '../reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

test('refresh courses', async () => {
  const courses = [courseTemplate.course()]
  const customColors = courseTemplate.customColors()
  let action = CoursesActions({ getCourses: apiResponse(courses), getCustomColors: apiResponse(customColors) }).refreshCourses()
  let state = await testAsyncReducer(coursesReducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      courses: [],
    },
    {
      pending: 0,
      courses: courses,
      customColors: {
        '1': '#fff',
      },
    },
  ])
})

test('refresh courses with error', async () => {
  let action = CoursesActions({ getCourses: apiError({ message: 'no courses' }), getCustomColors: apiError({ message: 'no courses' }) }).refreshCourses()
  let state = await testAsyncReducer(coursesReducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      courses: [],
    },
    {
      pending: 0,
      error: 'no courses',
      courses: [],
    },
  ])
})

test('toggleFavorite favorites a course', async () => {
  let course = courseTemplate.course({ is_favorite: false })
  let action = FavoritesActions({ favoriteCourse: apiResponse() }).toggleFavorite(course.id.toString(), true)
  let initialState = {
    ...defaultState,
    courses: [course],
  }
  let state = await testAsyncReducer(coursesReducer, action, initialState)
  let courses = [{
    ...course,
    is_favorite: true,
  }]
  expect(state).toEqual([
    {
      pending: 1,
      courses,
    },
    {
      pending: 0,
      courses,
    },
  ])
})

test('toggleFavorite unfavorites a course', async () => {
  let course = courseTemplate.course({ is_favorite: true })
  let action = FavoritesActions({ unfavoriteCourse: apiResponse() }).toggleFavorite(course.id.toString(), false)
  let initialState = {
    ...defaultState,
    courses: [course],
  }
  let state = await testAsyncReducer(coursesReducer, action, initialState)
  let courses = [{
    ...course,
    is_favorite: false,
  }]

  expect(state).toEqual([
    {
      pending: 1,
      courses,
    },
    {
      pending: 0,
      courses,
    },
  ])
})

test('toggleFavorite reverts favorite on error', async () => {
  let course = courseTemplate.course({ is_favorite: false })
  let action = FavoritesActions({ favoriteCourse: apiError({ message: 'error' }) }).toggleFavorite(course.id.toString(), true)
  let initialState = {
    ...defaultState,
    courses: [course],
  }
  let state = await testAsyncReducer(coursesReducer, action, initialState)

  expect(state).toEqual([
    {
      pending: 1,
      courses: [{
        ...course,
        is_favorite: true,
      }],
    },
    {
      pending: 0,
      error: 'error',
      courses: [{
        ...course,
        is_favorite: false,
      }],
    },
  ])
})
