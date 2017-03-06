// @flow

const { test, expect } = global

import configureMockStore from 'redux-mock-store'

import { LegoActions } from '../actions'
import { defaultState } from '../reducer'
import promiseMiddleware from '../../../../utils/redux-promise'

const middlewares = [ promiseMiddleware ]
const mockStore = configureMockStore(middlewares)

declare var jest: any

test('buy lego set workflow', async () => {
  const set: LegoSet = {
    name: 'A Scurvy Pirate Ship',
    imageURL: 'https://lego.com/pirate-ship',
  }

  let _resolve = () => { throw new Error() }
  let data = new Promise((resolve) => { _resolve = resolve })

  let api = { buyLegoSet: jest.fn((set) => data) }
  let actions = LegoActions(api)
  let store = mockStore(defaultState)

  store.dispatch(actions.buyLegoSet(set))

  expect(store.getActions()).toHaveLength(1)
  expect(store.getActions()).toMatchObject([
    {
      type: actions.buyLegoSet.toString(),
      pending: true,
    },
  ])

  _resolve(set)
  await data

  expect(store.getActions()).toMatchObject([
    {
      type: actions.buyLegoSet.toString(),
      pending: true,
    },
    {
      type: actions.buyLegoSet.toString(),
      payload: set,
    },
  ])
})
