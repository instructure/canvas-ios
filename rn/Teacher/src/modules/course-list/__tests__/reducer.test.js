// @flow

import { CoursesActions } from '../actions'
import coursesReducer from '../reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'

const course: Course = {
  id: 1,
  name: 'foo 101',
  course_code: 'foo101',
  short_name: 'foo 101',
}

const customColor: CustomColors = {
  custom_colors: {
    course_1: '#fffff',
  },
}

test('refresh courses  ', async () => {
  let action = CoursesActions({ getCourses: apiResponse([course]), getCustomColors: apiResponse(customColor) }).refreshCourses()
  let state = await testAsyncReducer(coursesReducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      courses: [],
    },
    {
      pending: 0,
      courses: [course],
      customColors: {
        '1': '#fffff',
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
