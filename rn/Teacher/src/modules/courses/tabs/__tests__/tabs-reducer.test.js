/* @flow */

import { tabs, defaultState } from '../tabs-reducer'
import { TabsActions } from '../actions'
import { testAsyncReducer } from '../../../../../test/helpers/async'
import { apiResponse, apiError, DEFAULT_ERROR_MESSAGE } from '../../../../../test/helpers/apiMock'

const template = {
  ...require('../../../../api/canvas-api/__templates__/tab'),
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
      { pending: 0, tabs: [] },
    ])
  })

  it('sorts tabs by position', async () => {
    const one = template.tab({ id: 'assignments', position: 0 })
    const two = template.tab({ id: 'assignments', position: 1 })
    const three = template.tab({ id: 'assignments', position: 2 })
    const action = TabsActions({ getCourseTabs: apiResponse([three, one, two]) }).refreshTabs('1')

    const states = await testAsyncReducer(tabs, action)

    expect(states).toEqual([
      { pending: 1, tabs: [] },
      { pending: 0, tabs: [one, two, three] },
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
