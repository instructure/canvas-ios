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
      traitCollection: jest.fn(),
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

  test('replace', () => {
    const navigator = new Navigator('replace')
    navigator.replace('/courses/2')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'replace',
      '/courses/:courseID',
      { courseID: '2', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true, replace: true },
    )
  })

  test('present', () => {
    const navigator = new Navigator('present')
    navigator.show('/courses/1', { modal: true })
    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet' }
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

  test('traitCollection', () => {
    const navigator = new Navigator('traitCollection')
    const handler = () => {}
    navigator.traitCollection(handler)
    expect(NativeModules.Helm.traitCollection).toHaveBeenCalledWith('traitCollection', handler)
  })
})
