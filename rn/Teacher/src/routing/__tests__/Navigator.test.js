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
      pushFrom: jest.fn(() => Promise.resolve()),
      popFrom: jest.fn(() => Promise.resolve()),
      present: jest.fn(() => Promise.resolve()),
      dismiss: jest.fn(() => Promise.resolve()),
      dismissAllModals: jest.fn(() => Promise.resolve()),
      traitCollection: jest.fn(),
    }
  })

  it('forwards show as a push', () => {
    new Navigator('push').show('/courses/1')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'push',
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true }
    )
  })

  it('forwards pop to native helm', () => {
    new Navigator('pop').pop()
    expect(NativeModules.Helm.popFrom).toHaveBeenCalledWith('pop')
  })

  it('forwards replace as a push', () => {
    new Navigator('replace').replace('/courses/2')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'replace',
      '/courses/:courseID',
      { courseID: '2', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true, replace: true },
    )
  })

  it('forwards present to native helm', () => {
    new Navigator('present').show('/courses/1', { modal: true })
    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String) },
      { canBecomeMaster: true, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('forwards dismiss to native helm', () => {
    new Navigator('dismiss').dismiss()
    expect(NativeModules.Helm.dismiss).toHaveBeenCalledWith({})
  })

  it('forwards dismiss all to native helm', () => {
    new Navigator('dismiss all').dismissAllModals()
    expect(NativeModules.Helm.dismissAllModals).toHaveBeenCalledWith({})
  })

  it('traitCollection', () => {
    const handler = () => {}
    new Navigator('traitCollection').traitCollection(handler)
    expect(NativeModules.Helm.traitCollection).toHaveBeenCalledWith('traitCollection', handler)
  })
})
