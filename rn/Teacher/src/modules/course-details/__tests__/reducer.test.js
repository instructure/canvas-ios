/* @flow */

import { CourseDetailsActions } from '../actions'
import reducer from '../reducer'
import { apiResponse, apiError } from '../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../test/helpers/async'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

const template = {
  ...require('../../../api/canvas-api/__templates__/tab'),
}

test('refresh tabs', async () => {
  const tabs = [template.tab()]
  const colors = courseTemplate.customColors()
  let action = CourseDetailsActions({ getCourseTabs: apiResponse(tabs), getCustomColors: apiResponse(colors) }).refreshTabs(1)
  let state = await testAsyncReducer(reducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      tabs: [],
      courseColors: {},
    },
    {
      pending: 0,
      tabs: tabs,
      courseColors: {
        '1': '#fff',
      },
    },
  ])
})

test('refresh tabs with error', async () => {
  const api = {
    getCourseTabs: apiError(),
    getCustomColors: apiResponse({}),
  }
  const action = CourseDetailsActions(api).refreshTabs(1)
  const state = await testAsyncReducer(reducer, action)

  expect(state).toEqual([
    {
      pending: 1,
      tabs: [],
      courseColors: {},
    },
    {
      pending: 0,
      error: 'Could not get course information',
      tabs: [],
      courseColors: {},
    },
  ])
})
