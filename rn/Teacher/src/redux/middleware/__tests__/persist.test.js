// @flow

import { AsyncStorage } from 'react-native'
import mockStore from '../../../../test/helpers/mockStore'

jest.mock('AsyncStorage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
}))
jest.mock('../../../api/session')

let wait = () => new Promise(resolve => setTimeout(resolve, 1))

describe('persistMiddleware', () => {
  let store = mockStore()
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('persists into async storage', async () => {
    store.dispatch({
      type: 'action',
      payload: {},
    })

    await wait()
    expect(AsyncStorage.setItem).toHaveBeenCalled()
  })
})
