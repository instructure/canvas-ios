/* @flow */

import mockStore from '../mockStore'

describe('mockStore', () => {
  it('returns a mock store', () => {
    let store = mockStore()
    let action = { type: 'test' }
    store.dispatch(action)
    expect(store.getActions()).toEqual([action])
  })
})
