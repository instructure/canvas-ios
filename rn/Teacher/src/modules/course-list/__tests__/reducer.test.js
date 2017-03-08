// @flow

import { CoursesActions } from '../actions'
import coursesReducer from '../reducer'
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
