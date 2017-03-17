const { it, expect } = global
import 'react-native'
import type { Action } from 'redux'
import reduce from '../root-reducer'

const dummyAction: Action = { type: 'test.whoCares' }

it('contains toys subreducer', () => {
  const state: { toys: any } = reduce(undefined, dummyAction)
  expect(state.toys).toBeDefined()
})

it('contains courses subreducer', () => {
  const state: { courses: any } = reduce(undefined, dummyAction)
  expect(state.courses).toBeDefined()
})

test('subreducers count', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(5)
})
