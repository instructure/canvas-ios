// @flow

import { LegoActions } from '../actions'
import { defaultState } from '../reducer'
import { testAsyncAction } from '../../../../../test/helpers/async'
import { apiResponse } from '../../../../../test/helpers/apiMock'

test('buy lego set workflow', async () => {
  const set: LegoSet = {
    name: 'A Scurvy Pirate Ship',
    imageURL: 'https://lego.com/pirate-ship',
  }

  let actions = LegoActions({ buyLegoSet: apiResponse(set) })
  const result = await testAsyncAction(actions.buyLegoSet(set), defaultState)

  expect(result).toMatchObject([
    {
      type: actions.buyLegoSet.toString(),
      pending: true,
    },
    {
      type: actions.buyLegoSet.toString(),
      payload: { data: set },
    },
  ])
})
