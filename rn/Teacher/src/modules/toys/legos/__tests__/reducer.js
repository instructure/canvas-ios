// @flow

const { test, expect } = global
import { createStore, applyMiddleware } from 'redux'

import { LegoActions } from '../actions'
import legoSets from '../reducer'
import promiseMiddleware from '../../../../utils/redux-promise'

declare var jest: any

const set: LegoSet = {
  name: 'An Amazing Castle',
  imageURL: 'https://lego.com/castle',
}

test('buy lego set workflow', async () => {
  const store = createStore(legoSets, applyMiddleware(promiseMiddleware))

  let _resolve = () => { throw new Error() }
  let data = new Promise((resolve) => { _resolve = resolve })

  let api = { buyLegoSet: jest.fn((set) => data) }
  let actions = LegoActions(api)

  store.dispatch(actions.buyLegoSet(set))

  expect(store.getState()).toEqual({
    pending: 1,
    sets: [],
  })

  _resolve(set)
  await data

  expect(store.getState()).toEqual({
    pending: 0,
    sets: [set],
  })
})

test('buy lego set workflow - sad path', async () => {
  const store = createStore(legoSets, applyMiddleware(promiseMiddleware))

  let _reject = () => { throw new Error() }
  let data = new Promise((resolve, reject) => { _reject = reject })

  let api = { buyLegoSet: jest.fn((set) => data) }
  let actions = LegoActions(api)

  store.dispatch(actions.buyLegoSet(set))

  expect(store.getState()).toEqual({
    pending: 1,
    sets: [],
  })

  _reject()
  try {
    await data
  } catch (e) {
    expect(store.getState()).toEqual({
      pending: 0,
      sets: [],
      error: 'no monies ;(',
    })
  }
})
