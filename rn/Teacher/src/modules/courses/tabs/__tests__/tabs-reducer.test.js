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

/* @flow */

import { tabs, defaultState } from '../tabs-reducer'
import { TabsActions } from '../actions'
import { testAsyncReducer } from '../../../../../test/helpers/async'
import { apiResponse, apiError, DEFAULT_ERROR_MESSAGE } from '../../../../../test/helpers/apiMock'

const template = {
  ...require('../../../../__templates__/tab'),
}

describe('refresh tabs', () => {
  it('refreshes tabs', async () => {
    const oldTab = template.tab({ id: 'assignments', position: 0 })
    const newTab = { ...oldTab, position: 1 }
    const action = TabsActions({ getCourseTabs: apiResponse([newTab]) }).refreshTabs('1')
    const initialState = {
      ...defaultState,
      tabs: [oldTab],
    }

    const states = await testAsyncReducer(tabs, action, initialState)

    expect(states).toEqual([
      { pending: 1, tabs: [oldTab] },
      { pending: 0, tabs: [newTab] },
    ])
  })

  it('removes unsupported tabs', async () => {
    const tab = template.tab({ id: 'unsupported all day' })
    const action = TabsActions({ getCourseTabs: apiResponse([tab]) }).refreshTabs('1')

    const states = await testAsyncReducer(tabs, action)

    expect(states).toEqual([
      { pending: 1, tabs: [] },
      { pending: 0, tabs: [tab] },
    ])
  })

  it('tabs appear in the order they are received – sorting happens in map-state-to-props', async () => {
    const one = template.tab({ id: 'assignments', position: 0 })
    const two = template.tab({ id: 'assignments', position: 1 })
    const three = template.tab({ id: 'assignments', position: 2 })
    const action = TabsActions({ getCourseTabs: apiResponse([three, one, two]) }).refreshTabs('1')

    const states = await testAsyncReducer(tabs, action)

    expect(states).toEqual([
      { pending: 1, tabs: [] },
      { pending: 0, tabs: [three, one, two] },
    ])
  })

  it('handles error', async () => {
    const action = TabsActions({ getCourseTabs: apiError() }).refreshTabs('1')

    const states = await testAsyncReducer(tabs, action)

    expect(states).toEqual([
      { pending: 1, tabs: [] },
      { pending: 0, tabs: [], error: DEFAULT_ERROR_MESSAGE },
    ])
  })
})
