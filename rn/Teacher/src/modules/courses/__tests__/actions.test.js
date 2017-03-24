// @flow

import { CoursesActions } from '../actions'
import { testAsyncAction } from '../../../../test/helpers/async'
import { apiResponse } from '../../../../test/helpers/apiMock'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

let defaultState = {}

test('refresh courses workflow', async () => {
  const courses = [courseTemplate.course()]
  const colors = courseTemplate.customColors()
  let actions = CoursesActions({ getCourses: apiResponse(courses), getCustomColors: apiResponse(colors) })
  const result = await testAsyncAction(actions.refreshCourses())

  expect(result).toMatchObject([
    {
      type: actions.refreshCourses.toString(),
      pending: true,
    },
    {
      type: actions.refreshCourses.toString(),
      payload: [{ data: courses }, { data: colors }],
    },
  ])
})

test('update course color workflow', async () => {
  let response = { hexcode: '#fff' }
  let actions = CoursesActions({ updateCourseColor: apiResponse(response) })
  let state = {
    ...defaultState,
    customColors: {
      '1': '#333',
    },
  }
  const result = await testAsyncAction(actions.updateCourseColor('1', '#fff'), state)

  expect(result).toMatchObject([
    {
      type: actions.updateCourseColor.toString(),
      pending: true,
      payload: {
        courseID: '1',
        color: '#fff',
      },
    },
    {
      type: actions.updateCourseColor.toString(),
      payload: {
        result: { data: response },
        color: '#fff',
        courseID: '1',
      },
    },
  ])
})
