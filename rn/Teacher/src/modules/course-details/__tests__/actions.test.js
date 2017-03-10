/* @flow */

import { CourseDetailsActions } from '../actions'
import { defaultState } from '../reducer'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

const template = {
  ...require('../../../api/canvas-api/__templates__/tab'),
}

test('refresh tabs', async () => {
  const tabs = [template.tab()]
  const colors = courseTemplate.customColors()
  let actions = CourseDetailsActions({ getCourseTabs: apiResponse(tabs), getCustomColors: apiResponse(colors) })
  const result = await testAsyncAction(actions.refreshTabs(1), defaultState)

  expect(result).toMatchObject([
    {
      type: actions.refreshTabs.toString(),
      pending: true,
    },
    {
      type: actions.refreshTabs.toString(),
      payload: [{ data: tabs }, { data: colors }],
    },
  ])
})
