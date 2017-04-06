/* @flow */

import { TabsActions } from '../actions'
import { defaultState } from '../tabs-reducer'
import { apiResponse } from '../../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../../test/helpers/async'

const template = {
  ...require('../../../../api/canvas-api/__templates__/tab'),
}

test('refresh tabs', async () => {
  const tabs = [template.tab()]
  let actions = TabsActions({ getCourseTabs: apiResponse(tabs) })
  const result = await testAsyncAction(actions.refreshTabs('1'), defaultState)
  expect(result).toMatchObject([
    {
      type: actions.refreshTabs.toString(),
      pending: true,
      payload: { courseID: '1' },
    },
    {
      type: actions.refreshTabs.toString(),
      payload: {
        result: { data: tabs },
        courseID: '1',
      },
    },
  ])
})
