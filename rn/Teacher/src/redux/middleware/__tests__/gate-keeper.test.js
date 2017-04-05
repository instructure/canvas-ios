// @flow

import { Alert } from 'react-native'
import gateKeeperMiddleware, { updateAlertState } from '../gate-keeper'
import { updateStatus } from '../../../utils/online-status'
import hydrateAction from '../../hydrate-action'
import logoutAction from '../../logout-action'
import configureMockStore from 'redux-mock-store'

let mockStore = configureMockStore([gateKeeperMiddleware])

jest.mock('Alert', () => ({
  alert: jest.fn(),
}))

const template = {
  ...require('../../../redux/__templates__/app-state'),
}

describe('gateKeeper middleware', () => {
  beforeEach(() => {
    jest.resetAllMocks()
    updateAlertState(false)
  })

  it('doesnt let anything through when the user is not logged in', () => {
    let store = mockStore()

    store.dispatch({
      type: 'action',
    })

    expect(store.getActions()).toEqual([])
  })

  it('lets actions through when the user is logged in', () => {
    let store = mockStore()
    let cachedState = {
      expires: new Date(),
      state: template.appState(),
    }
    let action = hydrateAction(cachedState)
    store.dispatch(action)
    store.dispatch({ type: 'action' })

    expect(store.getActions()).toEqual([
      action,
      { type: 'action' },
    ])
  })

  it('stops letting actions through when the user logs out', () => {
    let store = mockStore()
    let cachedState = {
      expires: new Date(),
      state: template.appState(),
    }
    let action = hydrateAction(cachedState)
    store.dispatch(action)
    store.dispatch(logoutAction)
    store.dispatch({ type: 'action' })

    expect(store.getActions()).toEqual([
      action,
      logoutAction,
    ])
  })

  it('wont try to open the alert again while it is open', () => {
    let store = mockStore()
    let cachedState = {
      expires: new Date(),
      state: template.appState(),
    }
    let action = hydrateAction(cachedState)
    store.dispatch(action)

    updateStatus('none')

    let asyncAction = { type: 'action', payload: Promise.resolve() }
    store.dispatch(asyncAction)
    store.dispatch(asyncAction)

    expect(Alert.alert).toHaveBeenCalledTimes(1)
  })

  it('will let through a non async action when you are offline', () => {
    let store = mockStore()
    let cachedState = {
      expires: new Date(),
      state: template.appState(),
    }
    let action = hydrateAction(cachedState)
    store.dispatch(action)

    updateStatus('none')

    store.dispatch({ type: 'action' })

    expect(store.getActions()).toEqual([
      action,
      { type: 'action' },
    ])
  })
})
