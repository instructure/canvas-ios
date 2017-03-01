// @flow

const { it, expect } = global
import 'react-native'
import type { Action } from 'redux'
import reduce from '../reducer'

const dummyAction: Action = { type: 'test.whoCares' }

it('contains legoSets subreducer', () => {
  const state: { legoSets: any } = reduce(undefined, dummyAction)
  expect(state.legoSets).toBeDefined()
})

it('contains action figures subreducer', () => {
  const state: { actionFigures: any } = reduce(undefined, dummyAction)
  expect(state.actionFigures).toBeDefined()
})

it('contains exactly 2 subreducers', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(2)
})
