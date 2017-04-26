// @flow

import 'react-native'
import type { Action } from 'redux'
import reduce from '../root-reducer'
import hydrateAction from '../hydrate-action'
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

test('contains drawer subreducer', () => {
  const state: AppState = reduce(undefined, dummyAction)
  expect(state.drawer).toBeDefined()
})

test('subreducers count', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(3)
})

test('hydrate action will hydrate the store when the expiration is still in the future', () => {
  let state = reduce(undefined, dummyAction)

  let cachedState = {
    ...state,
    favoriteCourses: {
      yo: 'yo',
      pending: 0,
      courseRefs: [],
    },
  }
  let expiration = new Date()
  expiration.setDate(expiration.getDate() + 1)

  let action = hydrateAction({
    expires: expiration,
    state: cachedState,
  })

  const newState = reduce(state, action)
  expect(newState).toEqual(cachedState)
})

test('hydrate action will not hydrate the store when the expiration is in the past', () => {
  let state = reduce(undefined, dummyAction)

  let cachedState = {
    ...state,
    favoriteCourses: {
      yo: 'yo',
      pending: 0,
      courseRefs: [],
    },
  }
  let expiration = new Date(0)

  let action = hydrateAction({
    expires: expiration,
    state: cachedState,
  })

  const newState = reduce(state, action)
  expect(newState).toEqual(state)
})

test('logout action', () => {
  const state: {} = reduce(undefined, logout)
  expect(Object.keys(state).length).toEqual(3)
})
