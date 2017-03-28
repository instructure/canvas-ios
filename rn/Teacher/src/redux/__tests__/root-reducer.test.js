// @flow

import 'react-native'
import type { Action } from 'redux'
import reduce from '../root-reducer'

const dummyAction: Action = { type: 'test.whoCares' }

test('contains entities subreducer', () => {
  const state: CoursesAppState = reduce(undefined, dummyAction)
  expect(state.entities).toBeDefined()
})

test('contains entities.courses subreducer', () => {
  const state: CoursesAppState = reduce(undefined, dummyAction)
  expect(state.entities.courses).toBeDefined()
})

test('contains favoriteCourses subreducer', () => {
  const state: CoursesAppState = reduce(undefined, dummyAction)
  expect(state.favoriteCourses).toBeDefined()
})

test('subreducers count', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(2)
})
