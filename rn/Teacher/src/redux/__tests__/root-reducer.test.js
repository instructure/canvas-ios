// @flow

import 'react-native'
import type { Action } from 'redux'
import reduce from '../root-reducer'
import logout from '../logout-action'

const dummyAction: Action = { type: 'test.whoCares' }

test('contains entities subreducer', () => {
  const state: AppState = reduce(undefined, dummyAction)
  expect(state.entities).toBeDefined()
})

test('contains entities.courses subreducer', () => {
  const state: AppState = reduce(undefined, dummyAction)
  expect(state.entities.courses).toBeDefined()
})

test('contains entities.gradingPeriods subreducer', () => {
  const state = reduce(undefined, dummyAction)
  expect(state.entities.gradingPeriods).toBeDefined()
})

test('contains favoriteCourses subreducer', () => {
  const state: AppState = reduce(undefined, dummyAction)
  expect(state.favoriteCourses).toBeDefined()
})

test('subreducers count', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(2)
})

test('logout action', () => {
  const state: {} = reduce(undefined, logout)
  expect(Object.keys(state).length).toEqual(2)
})
