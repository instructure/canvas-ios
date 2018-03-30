//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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

test('contains quizzes subreducer', () => {
  const state: AppState = reduce(undefined, dummyAction)
  expect(state.entities.quizzes).toBeDefined()
})

test('subreducers count', () => {
  const state: {} = reduce(undefined, dummyAction)
  expect(Object.keys(state).length).toEqual(8)
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
  expect(Object.keys(state).length).toEqual(8)
})
