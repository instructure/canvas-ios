//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

  it('expands short cross-shard ids in html_url', async () => {
    const response = [
      template.tab({ html_url: '/courses/1234~5678' }),
      template.tab({ html_url: '/courses/1234~890/page' }),
      template.tab({ html_url: '/courses/1234890/link' }),
    ]
    const action = TabsActions({ getCourseTabs: apiResponse(response) }).refreshTabs('1')
    const states = await testAsyncReducer(tabs, action)

    expect(states[1].tabs[0].html_url).toBe('/courses/12340000000005678')
    expect(states[1].tabs[1].html_url).toBe('/courses/12340000000000890/page')
    expect(states[1].tabs[2].html_url).toBe('/courses/1234890/link')
  })
})
