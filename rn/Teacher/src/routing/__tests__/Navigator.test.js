// @flow

import {
  NativeModules,
} from 'react-native'

import { registerScreens } from '../register-screens'
import Navigator from '../Navigator'

registerScreens({})

describe('Navigator', () => {
  beforeEach(() => {
    jest.resetAllMocks()

    NativeModules.Helm = {
      pushFrom: jest.fn(),
      popFrom: jest.fn(),
      present: jest.fn(),
      dismiss: jest.fn(),
      dismissAllModals: jest.fn(),
    }
  })

  test('push', () => {
    const navigator = new Navigator('push')
    navigator.show('/courses/1')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'push',
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true }
    )
  })

  test('pop', () => {
    const navigator = new Navigator('pop')
    navigator.pop()
    expect(NativeModules.Helm.popFrom).toHaveBeenCalledWith('pop')
  })

  test('present', () => {
    const navigator = new Navigator('present')
    navigator.show('/courses/1', { modal: true })
    // ["/courses/:courseID", {"courseID": "1"}, {"embedInNavigationController": true, "modal": true, "modalPresentationStyle": undefined}]
    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true, embedInNavigationController: true, modal: true }
    )
  })

  test('dismiss', () => {
    const navigator = new Navigator('dismiss')
    navigator.dismiss()
    expect(NativeModules.Helm.dismiss).toHaveBeenCalledWith({})
  })

  test('dismiss all', () => {
    const navigator = new Navigator('dismiss all')
    navigator.dismissAllModals()
    expect(NativeModules.Helm.dismissAllModals).toHaveBeenCalledWith({})
  })
})
