// @flow

import { AsyncStorage } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'
import { hydrateStoreFromPersistedState } from '../persist'

jest.mock('AsyncStorage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(),
  multiRemove: jest.fn(),
}))
jest.mock('../../../api/session')

let wait = () => new Promise(resolve => setTimeout(resolve, 1))

describe('persistMiddleware', () => {
  let store
  beforeEach(() => {
    jest.resetAllMocks()
    store = mockStore()
  })

  it('persists into async storage', async () => {
    store.dispatch({
      type: 'action',
      payload: {},
    })

    await wait()
    expect(AsyncStorage.setItem).toHaveBeenCalled()
  })

  it('removes old states', async () => {
    AsyncStorage.getItem = jest.fn(() => null)
    AsyncStorage.getAllKeys = jest.fn(() => {
      return ['redux.state.1.0', 'something-else']
    })
    AsyncStorage.multiRemove = jest.fn()
    AsyncStorage.setItem = jest.fn()
    store.dispatch({
      type: 'action',
      payload: {},
    })

    await hydrateStoreFromPersistedState(store)
    expect(AsyncStorage.multiRemove).toHaveBeenCalledWith(['redux.state.1.0'])
  })
})
