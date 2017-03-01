// @flow

const { it, expect } = global
import store from '../store'

it('looks like a redux store', () => {
  expect(store.dispatch).toBeDefined()
  expect(store.getState()).toBeDefined()
})
