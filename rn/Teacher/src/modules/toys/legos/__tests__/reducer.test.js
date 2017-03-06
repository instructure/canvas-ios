// @flow

import { LegoActions } from '../actions'
import legoSets from '../reducer'
import { apiResponse, apiError } from '../../../../../test/helpers/apiMock'
import { testAsyncReducer } from '../../../../../test/helpers/async'

declare var jest: any

const set: LegoSet = {
  name: 'An Amazing Castle',
  imageURL: 'https://lego.com/castle',
}

test('buy lego set resolved', async () => {
  let action = LegoActions({ buyLegoSet: apiResponse([set]) }).buyLegoSet(set)
  let state = await testAsyncReducer(legoSets, action)

  expect(state).toEqual([
    {
      pending: 1,
      sets: [],
    },
    {
      pending: 0,
      sets: [set],
    },
  ])
})

test('buy lego set rejected', async () => {
  let action = LegoActions({ buyLegoSet: apiError() }).buyLegoSet(set)
  let state = await testAsyncReducer(legoSets, action)

  expect(state).toEqual([
    {
      pending: 1,
      sets: [],
    },
    {
      pending: 0,
      error: 'no monies ;(',
      sets: [],
    },
  ])
})
