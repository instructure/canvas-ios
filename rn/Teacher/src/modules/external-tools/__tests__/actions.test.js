// @flow

import { LTIActions } from '../actions'
import { apiResponse } from '../../../../test/helpers/apiMock'
import { testAsyncAction } from '../../../../test/helpers/async'

const template = {
  ...require('../../../__templates__/external-tool'),
}

test('fetch LTI launch definitions', async () => {
  const definitions = [template.ltiLaunchDefinition()]
  let actions = LTIActions({ getLTILaunchDefinitions: apiResponse(definitions) })
  const result = await testAsyncAction(actions.refreshLTITools('555'))
  expect(result).toMatchObject([
    {
      type: actions.refreshLTITools.toString(),
      pending: true,
      payload: { courseID: '555' },
    },
    {
      type: actions.refreshLTITools.toString(),
      payload: {
        result: { data: definitions },
        courseID: '555',
      },
    },
  ])
})
